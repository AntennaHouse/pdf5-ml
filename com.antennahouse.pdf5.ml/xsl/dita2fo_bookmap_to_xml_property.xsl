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

    <!--Adopt preprocess2 -->
    <xsl:param name="PRM_ADOPT_PREPROCESS2" as="xs:string" required="yes"/>
    <xsl:variable name="gAdoptPreprocess2" as="xs:boolean" select="$PRM_ADOPT_PREPROCESS2 eq $cYes"/>
    <xsl:variable name="gNotAdoptPreprocess2" as="xs:boolean" select="not($gAdoptPreprocess2)"/>
    
    <!-- .job.xml uri: used only when $gAdoptPreprocess2 is true -->
    <xsl:param name="PRM_JOB_XML_URI" as="xs:string" required="yes"/>
    <xsl:variable name="gJobUriDoc" as="document-node()">
        <xsl:choose>
            <xsl:when test="$gAdoptPreprocess2">
                <xsl:sequence select="doc($PRM_JOB_XML_URI)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:document/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- 
     function:  map matching template
     param:     none
     return:    <map> element.
     note:      
     -->
    <xsl:template match="*[@class => contains-token('map/map')][$gNotAdoptPreprocess2]">
        <xsl:element name="map">
            <!-- Link resource targets -->
            <xsl:variable name="resourecTopicRef" as="element()*" select="descendant::*[contains-token(@class, 'map/topicref')][string(@processing-role) eq 'resource-only'][string(@outputclass) = $gLinkTargetOutputClass][@href]"/>
            <xsl:variable name="targetHrefs" as="xs:string*">
                <xsl:for-each select="$resourecTopicRef">
                    <xsl:sequence select="ahf:bsToSlash(string(@href))"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:element name="link-target">
                <xsl:value-of select="string-join($targetHrefs,',')"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- 
     function:  map matching template
     param:     none
     return:    <map> element.
     note:      
     -->
    <xsl:template match="*[@class => contains-token('map/map')][$gAdoptPreprocess2]">
        <xsl:element name="map">
            <!-- Link resource targets -->
            <xsl:variable name="resourecTopicRef" as="element()*" select="descendant::*[contains-token(@class, 'map/topicref')][string(@processing-role) eq 'resource-only'][string(@outputclass) = $gLinkTargetOutputClass][@href]"/>
            <xsl:variable name="targetHrefs" as="xs:string*">
                <xsl:for-each select="$resourecTopicRef">
                    <xsl:variable name="href" as="xs:string" select="string(@href)"/>
                    <xsl:variable name="path" as="xs:string" select="string($gJobUriDoc/job/files/file[string(@uri) eq $href]/@result)"/>
                    <xsl:if test="starts-with($path,'file:/')">
                        <xsl:sequence select="substring-after($path,'file:/')"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:element name="link-target">
                <xsl:value-of select="string-join($targetHrefs,',')"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>