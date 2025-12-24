<?xml version="1.0" encoding="UTF-8" ?>
<!--
    **************************************************************
    DITA to XSL-FO Stylesheet
    Error processing Templates
    **************************************************************
    File Name : dita2fo_error_util.xsl
    **************************************************************
    Copyright © 2009 2009 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL : http://www.antennahouse.com/
    **************************************************************
-->

<xsl:stylesheet version="3.0" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
 	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >
    
    <!--
    ===============================================
     Error processing
    ===============================================
    -->

    <!-- Error message prefixes -->
    <xsl:variable name="internalErrorPrefixStr" as="xs:string" select="'[INTERNAL ERROR][CALL DEVELOPER]'"/>
    <xsl:variable name="fatalErrorPrefixStr" as="xs:string" select="'[FATAL ERROR]'"/>
    <xsl:variable name="errorPrefixStr" as="xs:string" select="'[ERROR]'"/>
    <xsl:variable name="warningPrefixStr" as="xs:string" select="'[WARNING]'"/>
    <xsl:variable name="infoPrefixStr" as="xs:string" select="'[INFO]'"/>

    <!-- Terminate message when xsl:message/@terminate="yes"
         Probably not shown when invoked by "ant" command
      -->
    <xsl:variable name="cTerminateMes" as="xs:string" static="yes" select="'[ABORT] Terminated because of fatal error!'"/>
    
    <!-- 
     function:  Internal Error Exit template
     param:     prmMes: message body
     return:    none
     note:      Intended to use program logical error
    -->
    <xsl:template name="internalError">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$internalErrorPrefixStr || $prmMes"/>
        <xsl:message terminate="yes" select="$cTerminateMes"/>
    </xsl:template>
    
    <xsl:template name="internalErrorWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$internalErrorPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
        <xsl:message terminate="yes" select="$cTerminateMes"/>
    </xsl:template>
    
    <xsl:template name="internalErrorContinue">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$internalErrorPrefixStr || $prmMes"/>
    </xsl:template>
    
    <xsl:template name="internalErrorContinueWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$internalErrorPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
    </xsl:template>
    
    <!-- 
     function:  Error Exit template
     param:     prmMes: message body
     return:    none
     note:      none
    -->
    <xsl:template name="errorExit">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$fatalErrorPrefixStr || $prmMes"/>
        <xsl:message terminate="yes" select="$cTerminateMes"/>
    </xsl:template>
    
    <xsl:template name="errorExitWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$fatalErrorPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
        <xsl:message terminate="yes" select="$cTerminateMes"/>
    </xsl:template>
    
    <!-- 
     function:  Error Continue template
     param:     prmMes: message body
     return:    none
     note:      none
    -->
    <xsl:template name="errorContinue">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$errorPrefixStr || $prmMes"/>
    </xsl:template>
    
    <xsl:template name="errorContinueWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$errorPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
    </xsl:template>
    
    <!-- 
     function:  Warning display template
     param:     prmMes: message body
     return:    none
     note:      none
    -->
    <xsl:template name="warningContinue">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$warningPrefixStr || $prmMes"/>
    </xsl:template>
    
    <xsl:template name="warningContinueWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$warningPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
    </xsl:template>
    
    <!-- 
     function:  Warning display template
     param:     prmMes: message body
     return:    none
     note:      none
    -->
    <xsl:template name="infoContinue">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no" select="$infoPrefixStr || $prmMes"/>
    </xsl:template>
    
    <xsl:template name="infoContinueWithFileInfo">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:param name="prmElem" required="yes" as="element()?"/>
        <xsl:variable name="elemFileInfo" as="xs:string" select="ahf:getFileInfoOfElem($prmElem)"/>
        <xsl:message terminate="no" select="$infoPrefixStr || $prmMes || ' ' || $elemFileInfo"/>
    </xsl:template>
    
    <!--
     function:   get line number & column number from @xtrc
     param:      prmElem
     return:     xs:string+
     note:       
    -->
    <xsl:variable name="cUnavailableNumber" as="xs:string" select="'Unavailable'"/>
    
    <xsl:function name="ahf:getLineAndColumnNumberOfElem" as="xs:string+">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="xtrc" as="xs:string?" select="$prmElem/@xtrc => string()"/>
        <xsl:choose>
            <xsl:when test="$xtrc eq ''">
                <xsl:sequence select="($cUnavailableNumber,$cUnavailableNumber)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="lineAndColumnPart" as="xs:string" select="substring-after($xtrc,';')"/>
                <xsl:choose>
                    <xsl:when test="$lineAndColumnPart eq ''">
                        <xsl:sequence select="($cUnavailableNumber,$cUnavailableNumber)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="line" as="xs:string" select="substring-before($lineAndColumnPart,':')"/>
                        <xsl:variable name="column" as="xs:string" select="substring-after($lineAndColumnPart,':')"/>
                        <xsl:sequence select="(if ($line eq '') then $cUnavailableNumber else $line, if ($column eq '') then $cUnavailableNumber else $column)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
     function:   get file path from @xtrf
     param:      prmElem
     return:     xs:string
     note:       
    -->
    <xsl:variable name="cUnavailableFile" as="xs:string" select="'Unavailable'"/>
    
    <xsl:function name="ahf:getFileNameOfElem" as="xs:string+">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="xtrf" as="xs:string?" select="$prmElem/@xtrf => string()"/>
        <xsl:sequence select="if (exists($xtrf)) then $xtrf else $cUnavailableFile"/>
    </xsl:function>        
    
    <!--
     function:   get file path, line and column information from element
     param:      prmElem
     return:     xs:string
     note:       
     -->
    <xsl:function name="ahf:getFileInfoOfElem" as="xs:string">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="filePath" as="xs:string" select="ahf:getFileNameOfElem($prmElem)"/>
        <xsl:variable name="lineAndColumn" as="xs:string+" select="ahf:getLineAndColumnNumberOfElem($prmElem)"/>
        <xsl:sequence select="'Path=''' || $filePath || ''' Line=' || $lineAndColumn[1] || ' Column=' || $lineAndColumn[2] "/>
    </xsl:function>     
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
