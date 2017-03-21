<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Common templates
Copyright © 2009-2011 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf" 
>
    <!-- =======================
          Debug templates
         =======================
     -->
    
    <!-- 
     function:	General template for debug
     param:	    
     return:	debug message
     note:		
     -->
    <xsl:template match="*" priority="-3">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes"
             select="ahf:replace($stMes001,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Text-only templates are moved to dita2fo_text_mode.xsl -->
    
    <!-- ========================
          Get contenst as inline
         ========================
     -->
    <!-- 
     function:	Get target contents copy as inline
     param:		none
     return:	fo:inline
     note:		** DOES NOT GENERATE @id & PROCESS INDEXTERM. **
     -->
    <xsl:template match="*" mode="GET_CONTENTS">
        <fo:inline>
            <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmGetContent" tunnel="yes" select="true()"/>
            </xsl:apply-templates>
        </fo:inline>
    </xsl:template>
    
    <!-- makeBlankBlock, genThumbInex and genThumbIndexMain are moved to dita2fo_staticcontent.xsl -->
    
    <!-- ahf:getTitleMode is moved to dita2_fo.title.xsl -->
    
    <!-- =====================================
          indexterm related common template
         ===================================== -->
    <!-- Moved into dita2fo_indexcommon.xsl -->

</xsl:stylesheet>
