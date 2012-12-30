package org.chorusbdd.chorus.tools.webagent;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.chorusbdd.chorus.executionlistener.ExecutionListenerAdapter;
import org.chorusbdd.chorus.results.ExecutionToken;
import org.chorusbdd.chorus.results.FeatureToken;
import org.chorusbdd.chorus.tools.webagent.util.WebAgentUtil;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 * User: nick
 * Date: 24/12/12
 * Time: 22:39
 *
 * Cache containing a history of TestSuite metadata tokens by time
 * Limited to a preset maximum size
 */
public class WebAgentFeatureCache extends ExecutionListenerAdapter {

    private static final Log log = LogFactory.getLog(JmxManagementServerExporter.class);

    private final LinkedList<WebAgentTestSuite> cachedSuites = new LinkedList<WebAgentTestSuite>();
    private final AtomicLong suitesReceived = new AtomicLong();
    private final String cacheName;
    private String httpName;
    private volatile int maxSuiteHistory;

    public WebAgentFeatureCache(String cacheName, int maxSuiteHistory) {
        this.cacheName = cacheName;
        this.maxSuiteHistory = maxSuiteHistory;
        setHttpName();
    }

    public void testsCompleted(ExecutionToken testExecutionToken, List<FeatureToken> features) {
        WebAgentTestSuite testSuite = new WebAgentTestSuite(testExecutionToken, features);
        addToCachedSuites(testSuite);
    }

    private void addToCachedSuites(WebAgentTestSuite testSuite) {
        synchronized ( cachedSuites ) {
            cachedSuites.add(testSuite);
            suitesReceived.incrementAndGet();
            if ( cachedSuites.size() > maxSuiteHistory) {
                cachedSuites.removeLast();
            }
        }
    }

    @Override
    public String toString() {
        return "WebAgentFeatureCache{" +
                "cacheName='" + cacheName + '\'' +
                ", maxSuiteHistory=" + maxSuiteHistory +
                '}';
    }

    public int getNumberOfTestSuites() {
        synchronized (cachedSuites) {
            return cachedSuites.size();
        }
    }

    public void setMaxHistory(int maxHistory) {
        this.maxSuiteHistory = maxHistory;
        synchronized (cachedSuites) {
            while ( cachedSuites.size() > 0 && cachedSuites.size() > maxHistory) {
                cachedSuites.removeLast();
            }
        }
    }

    public Object getMaxHistory() {
        return maxSuiteHistory;
    }

    public int getSuitesReceived() {
        return suitesReceived.intValue();
    }

    public String getName() {
        return cacheName;
    }

    public void setHttpName() {
        httpName = WebAgentUtil.urlEncode(cacheName);
    }

    public String getHttpName() {
        return httpName;
    }

    public List<WebAgentTestSuite> getSuites() {
        return getSuites(TestSuiteFilter.ALL_SUITES);
    }

    public List<WebAgentTestSuite> getSuites(TestSuiteFilter testSuiteFilter) {
        List<WebAgentTestSuite> l = new LinkedList<WebAgentTestSuite>();
        synchronized (cachedSuites) {
            for ( WebAgentTestSuite s : cachedSuites) {
                if ( testSuiteFilter.accept(s)) {
                    l.add(s);
                }
            }
        }
        return l;
    }
}
