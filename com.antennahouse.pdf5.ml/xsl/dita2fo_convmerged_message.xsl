<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
Message definition for convmerged
**************************************************************
File Name : dita2fo_convmerged_message.xsl
**************************************************************
Copyright © 2009 2009 Antenna House, Inc.All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">
    <!--
    ===============================================
    Message Definition
    ===============================================
    -->
    <xsl:variable name="stMes1001" as="xs:string">
        <xsl:text>[convmerged 1001I] Removing topicref. href=%href ohref=%ohref</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="stMes1002" as="xs:string">
        <xsl:text>[convmerged 1002I] Removing topic. id=%id xtrf=%xtrf</xsl:text>
    </xsl:variable>

    <xsl:variable name="stMes1003" as="xs:string">
        <xsl:text>[convmerged 1003I] Removing link. href=%href</xsl:text>
    </xsl:variable>

    <xsl:variable name="stMes1004" as="xs:string">
        <xsl:text>[convmerged 1004W] Warning! Xref refers to removed topic. href=%href</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="stMes1010" as="xs:string">
        <xsl:text>[convmerged 1010F] Topichead or topicgroup are ignored at child of booklists/glossarylist. xtrc=%xtrc</xsl:text>
    </xsl:variable>
    
</xsl:stylesheet>
