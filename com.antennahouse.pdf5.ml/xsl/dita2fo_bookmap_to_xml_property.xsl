<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to FO Stylesheet
    Module: Bookmap to XML property file templates
    Copyright © 2017-2020 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf ahs" 
    >
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_constants.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_util.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_error_util.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_message.xsl/"/>
    
    <!--Referenced resources @outputclass -->
    <xsl:param name="PRM_LINK_TARGET_OUTPUT_CLASS" as="xs:string" required="yes"/>
    <xsl:variable name="gLinkTargetOutputClass" as="xs:string+" select="tokenize($PRM_LINK_TARGET_OUTPUT_CLASS, '[;,\s]')"/>

    <!-- .job.xml uri -->
    <xsl:param name="PRM_JOB_XML_URI" as="xs:string" required="yes"/>
    <xsl:variable name="gJobUriDoc" as="document-node()">
        <xsl:sequence select="doc($PRM_JOB_XML_URI)"/>
    </xsl:variable>
    

    <!-- 
     function:  map matching template
     param:     none
     return:    <map> element.
     note:      
     -->
    <xsl:template match="*[@class => contains-token('map/map')]">
        <xsl:element name="map">
            <!-- Link resource targets -->
            <xsl:variable name="resourecTopicRef" as="element()*" select="descendant::*[contains-token(@class, 'map/topicref')][string(@processing-role) eq 'resource-only'][string(@outputclass) = $gLinkTargetOutputClass][@href]"/>
            <xsl:variable name="targetHrefs" as="xs:string*">
                <xsl:for-each select="$resourecTopicRef">
                    <xsl:variable name="href" as="xs:string" select="string(@href)"/>
                    <xsl:variable name="path" as="xs:string" select="string($gJobUriDoc/job/files/file[string(@uri) eq $href]/@result)"/>
                    <xsl:choose>
                        <xsl:when test="starts-with($path,'file:/')">
                            <xsl:sequence select="substring-after($path,'file:/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes5034,('%href'),($href))"/>
                            </xsl:call-template>                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:element name="link-target">
                <xsl:value-of select="string-join($targetHrefs,',')"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>