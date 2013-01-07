package org.chorusbdd.chorus.tools.webagent.jettyhandler;

import org.chorusbdd.chorus.tools.webagent.TestSuiteFilter;
import org.chorusbdd.chorus.tools.webagent.WebAgentFeatureCache;
import org.chorusbdd.chorus.tools.webagent.WebAgentTestSuite;
import org.chorusbdd.chorus.tools.webagent.util.WebAgentUtil;
import org.eclipse.jetty.server.Request;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import java.util.List;

/**
 * User: nick
 * Date: 27/12/12
 * Time: 16:31
 */
public abstract class AbstractSuiteListHandler extends XmlStreamingHandler {

    private WebAgentFeatureCache cache;
    private TestSuiteFilter testSuiteFilter;
    private String handledPath;
    private String pathSuffix;
    private int localPort;
    private final String handledPathWithSuffix;

    public AbstractSuiteListHandler(WebAgentFeatureCache webAgentFeatureCache, TestSuiteFilter testSuiteFilter, String handledPath, String pathSuffix, int localPort) {
        this.cache = webAgentFeatureCache;
        this.testSuiteFilter = testSuiteFilter;
        this.handledPath = handledPath;
        this.pathSuffix = pathSuffix;
        this.localPort = localPort;
        this.handledPathWithSuffix = handledPath + pathSuffix;
    }

    @Override
    protected void doHandle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response, XMLStreamWriter writer) throws XMLStreamException {
        List<WebAgentTestSuite> suites = cache.getSuites(testSuiteFilter);
        doHandle(suites, target, baseRequest, request, response, writer);
    }

    protected abstract void doHandle(List<WebAgentTestSuite> suites, String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response, XMLStreamWriter writer) throws XMLStreamException;

    @Override
    protected boolean shouldHandle(String target) {
        return handledPathWithSuffix.equals(target);
    }

    public String getHandledPath() {
        return handledPath;
    }

    public WebAgentFeatureCache getCache() {
        return cache;
    }

    public int getLocalPort() {
        return localPort;
    }

    protected String getLinkToSuite(WebAgentTestSuite s) {
        String suiteHttpName = WebAgentUtil.urlEncode(s.getSuiteId());
        return "http://localhost:" + getLocalPort() + "/" + getCache().getHttpName() + "/testSuite.xml?suiteId=" + suiteHttpName;
    }
}
