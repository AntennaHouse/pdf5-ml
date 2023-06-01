<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Generate merged-middle file from sigle topic
    Copyright © 2009-2023 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:ahd="http://www.antennahouse.com/names/XSLT/Debugging"
 exclude-result-prefixes="ahf" 
>
    
    <!-- 
     function:	Output plug-in & XSLT processor information
     param:		none
     return:	
     note:		
     -->
    <xsl:template name="outputPluginInfo">
        <!-- Plug-in name and version -->
        <xsl:variable name="pluginAuthor" as="xs:string" select="'Antenna House'"/>
        <xsl:variable name="pluginName" as="xs:string" select="'PDF5-ML: Generate merged-middle file from single topic'"/>
        <xsl:variable name="pluginVersion" as="xs:string" select="'1.0.0'"/>
        <xsl:message select="concat($pluginAuthor,' ',$pluginName,' plug-in Version: ',$pluginVersion)"/>
        <!-- XSLT processor information -->
        <xsl:variable name="vendor" as="xs:string" select="system-property('xsl:vendor')"/>
        <xsl:variable name="vendorUrl" as="xs:string" select="system-property('xsl:vendor-url')"/>
        <xsl:variable name="productName" as="xs:string" select="system-property('xsl:product-name')"/>
        <xsl:variable name="productVersion" as="xs:string" select="system-property('xsl:product-version')"/>
        <xsl:message select="concat('Running on: ',$productName,' (',$vendorUrl,') Version: ',$productVersion)"/>
    </xsl:template>
    
    <!-- 
     function:  root matching template
     param:     none
     return:	dita-merge
     note:      This template inputs topic-only-prototype.xml and outputs [topic file name]_MERGED.xml in temporary folder.
     -->
    <xsl:template match="/">
        <xsl:call-template name="outputPluginInfo"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- 
     function:  dita-merge matching template
     param:     none
     return:	dita-merge
     note:      Output topic at the end of map contents.
     -->
    <xsl:template match="dita-merge">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
            <xsl:call-template name="outputTopic"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:  Genral node() template
     param:     none
     return:	itself
     note:      
     -->
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:  map
     param:     none
     return:    map
     note:      coompliment xml:lang
     -->
    <xsl:template match="map">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="$gpTopicFileDoc/*[@class => contains-token('topic/topic')]/@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:  topicref
     param:     none
     return:    topicref
     note:      none
     -->
    <xsl:template match="topicref">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="topicref/@ohref" priority="10">
        <!--xsl:message select="'[topicref/@ohref] Match!'"/-->
        <xsl:attribute name="ohref" select="$gpTopicFileDoc/*[@class => contains-token('topic/topic')]/@xtrf => string()"/>
    </xsl:template>
    
    <!-- 
     function:  Output topic
     param:     none
     return:    *[@class => contains-token('topic/topic')]
     note:      
     -->
    <xsl:template name="outputTopic">
        <xsl:apply-templates select="$gpTopicFileDoc/*"/>
    </xsl:template>    

    <xsl:template match="*[@class => contains-token('topic/topic')][ancestor::*[@class => contains-token('topic/topic')] => empty()]" priority="10">
        <!--xsl:message select="'[topic] Match!'"/-->
        <xsl:copy>
            <xsl:variable name="id" as="xs:string" select="@id => string()"/>
            <xsl:apply-templates select="@*">
                <xsl:with-param name="prmId" select="$id"/>
            </xsl:apply-templates>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[@class => contains-token('topic/topic')][ancestor::*[@class => contains-token('topic/topic')] => empty()]/@id" priority="10">
        <xsl:param name="prmId" as="xs:string" required="yes"/>
        <!--xsl:message select="'[@id] Match!'"/-->
        <xsl:attribute name="id" select="'unique_1'"/>
        <xsl:attribute name="oid" select="$prmId"/>
    </xsl:template>
    
</xsl:stylesheet>
