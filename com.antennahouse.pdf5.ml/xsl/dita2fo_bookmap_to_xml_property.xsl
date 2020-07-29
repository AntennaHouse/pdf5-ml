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
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf ahs" 
    >
    <xsl:import href="dita2fo_constants.xsl"/>
    <xsl:import href="dita2fo_util.xsl"/>
    <xsl:import href="dita2fo_error_util.xsl"/>
    <xsl:import href="dita2fo_message.xsl/"/>
    
    <!--Referenced resources @outputclass -->
    <xsl:variable name="gLinkTargetResourceOutputClass" as="xs:string+" select="('link-target')"/>
    
    <!-- 
     function:  map matching template
     param:     none
     return:    <map> element.
     note:      
     -->
    <xsl:template match="*[@class => contains-token('map/map')]">
        <xsl:variable name="xmlLang" as="xs:string" select="@xml:lang => string()"/>
        <xsl:element name="map">
            <!-- Link resource targets -->
            <xsl:variable name="resourecTopicRef" as="element()*" select="descendant::*[contains(@class,' map/topicref ')][string(@processing-role) eq 'resource-only'][ahf:seqContains(@outputclass,$gLinkTargetResourceOutputClass)]"/>
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

</xsl:stylesheet>