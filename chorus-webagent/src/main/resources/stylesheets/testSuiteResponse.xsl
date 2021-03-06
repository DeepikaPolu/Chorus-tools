<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html"/>
    <xsl:template match="/testSuite">
        <html>
            <head>
                <META HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
                <title><xsl:value-of select="@suiteName"/></title>
                <LINK href="testSuite.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
              <script language="javascript">
                  function hideOrShowFeatureBody(featureId, featureShowHideId) {
                    var featureDiv = document.getElementById(featureId);
                    var img = document.getElementById(featureShowHideId);
                    if ( featureDiv.className == "featureShown" ) {
                        featureDiv.className = "featureHidden";
                        img.src = "expand.png"
                    } else {
                        featureDiv.className = "featureShown";
                        img.src = "contract.png"
                    }
                  }
              </script>
             <div class="suiteDetails">
                <span class="suiteName">Test Suite: <xsl:value-of select="@suiteName"/></span><span class="suiteTimeTaken">
                 Host: <xsl:value-of select="execution/@executionHost"/>&#160;&#160;
                 Run time: <xsl:value-of select="execution/resultsSummary/@timeTakenSeconds"/> seconds
                </span>
                <div class="suiteExecutionTime"><xsl:value-of select="execution/@executionStartTime"/></div>
            </div>
                <xsl:apply-templates select="execution"/>
                <xsl:apply-templates select="features/feature"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="execution">
        <div class="results">
            <table class="resultsTable">
                <tr>
                    <th scope="col"/>
                    <th scope="col">Passed</th>
                    <th scope="col">Failed</th>
                    <th scope="col">Undefined</th>
                    <th scope="col">Pending</th>
                    <th scope="col">Skipped</th>
                </tr>
                <tr>
                    <th scope="row">Feature</th>
                    <td class="pass"><xsl:value-of select="resultsSummary/@featuresPassed"/></td>
                    <td class="fail"><xsl:value-of select="resultsSummary/@featuresFailed"/></td>
                    <td/>
                    <td/>
                    <td/>
                </tr>
                <tr>
                    <th scope="row">Scenario</th>
                    <td class="pass"><xsl:value-of select="resultsSummary/@scenariosPassed"/></td>
                    <td class="fail"><xsl:value-of select="resultsSummary/@scenariosFailed"/></td>
                    <td/>
                    <td/>
                    <td/>
                </tr>
                <tr>
                    <th scope="row">Step</th>
                    <td class="pass"><xsl:value-of select="resultsSummary/@stepsPassed"/></td>
                    <td class="fail"><xsl:value-of select="resultsSummary/@stepsFailed"/></td>
                    <td class="fail"><xsl:value-of select="resultsSummary/@stepsUndefined"/></td>
                    <td class="pend"><xsl:value-of select="resultsSummary/@stepsPending"/></td>
                    <td class="other"><xsl:value-of select="resultsSummary/@stepsSkipped"/></td>
                </tr>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="feature">
        <!-- show the configuration next to feature name when not base configuration -->
        <xsl:variable name="configuration">
            <xsl:choose>
                <xsl:when test="@configurationName='base'">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@configurationName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="feature">
            <xsl:variable name="featureId">
                <xsl:number count="feature"/>
            </xsl:variable>

            <xsl:variable name="showHideInitialImage">
                <xsl:choose>
                    <xsl:when test="@endState='PASSED'">
                        <xsl:value-of select="'expand.png'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'contract.png'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <div class="featureTitle">
                <a href="javascript:hideOrShowFeatureBody('featureBody{$featureId}', 'featureShowHide{$featureId}')"><img id="featureShowHide{$featureId}" src="{$showHideInitialImage}" class="expandContractImage"/></a>
                <xsl:value-of select="@name"/>&#160;<xsl:value-of select="$configuration"/>
            </div>

            <xsl:variable name="featureInitialClass">
                <xsl:choose>
                    <xsl:when test="@endState='PASSED'">
                        <xsl:value-of select="'featureHidden'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'featureShown'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <div id="featureBody{$featureId}" class="{$featureInitialClass}">
                <div class="featureDescription">
                <xsl:value-of select="description"/>
                </div>
                <xsl:apply-templates select="scenarios/scenario"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="scenario">
        <div class="scenario">
            <div class="scenarioTitle"><xsl:value-of select="@name"/></div>
            <div class="steps">
                <xsl:apply-templates select="steps/step"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="step">
        <div class="step">
            <xsl:variable name="stepClass">
                <xsl:choose>
                    <xsl:when test="@endState='PASSED'">
                        <xsl:value-of select="'GREEN'"/>
                    </xsl:when>
                    <xsl:when test="@endState='FAILED'">
                        <xsl:value-of select="'RED'"/>
                    </xsl:when>
                    <xsl:when test="@endState='UNDEFINED'">
                        <xsl:value-of select="'RED'"/>
                    </xsl:when>
                    <xsl:when test="@endState='PENDING'">
                        <xsl:value-of select="'ORANGE'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'GREY'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <span class="step{$stepClass}">
                <span class="stepText"><xsl:value-of select="@type"/>&#160;<xsl:value-of select="@action"/></span>
                <span class="endState"><xsl:value-of select="@endState"/></span>
                <span class="stepMessage"><xsl:value-of select="@message"/></span>
                <span class="timeTaken">(<xsl:value-of select="@timeTakenSeconds"/>s)</span>
            </span>
        </div>
    </xsl:template>

</xsl:stylesheet>