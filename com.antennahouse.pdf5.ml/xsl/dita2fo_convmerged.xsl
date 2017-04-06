<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Merged file conversion templates
Copyright © 2009-2013 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    
    <!-- map or bookmap: Already defined in dita2fo_global.xsl -->
    <xsl:variable name="map" as="element()" select="/*[1]/*[contains(@class,' map/map ')][1]"/>
    
    <!-- All topiref-->
    <xsl:variable name="allTopicRefs" as="element()*" select="$map//*[contains(@class,' map/topicref ')][not(ancestor::*[contains(@class,' map/reltable ')])]"/>
    
    <!-- topicref that has @print="no"-->
    <xsl:variable name="noPrintTopicRefs" as="element()*" select="$allTopicRefs[ancestor-or-self::*[string(@print) eq 'no']]"/>
    
    <!-- Normal topicref -->
    <xsl:variable name="normalTopicRefs" as="element()*" select="$allTopicRefs except $noPrintTopicRefs"/>
    
    <!-- @href of topicref that has @print="no"-->
    <xsl:variable name="noPrintHrefs" as="xs:string*">
        <xsl:for-each select="$noPrintTopicRefs">
            <xsl:if test="exists(@href)">
                <xsl:sequence select="string(@href)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- @href of noraml topicref -->
    <xsl:variable name="normalHrefs" as="xs:string*">
        <xsl:for-each select="$normalTopicRefs">
            <xsl:if test="exists(@href)">
                <xsl:sequence select="string(@href)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- 
     function:	General template for all element
     param:		none
     return:	copied result
     note:		
     -->
    <xsl:template match="*">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:	topicgroup
     param:		none
     return:	descendant element
     note:		An topicgroup is redundant for document structure.
                It sometimes bothers counting the nesting level of topicref.
     -->
    <xsl:template match="*[contains(@class, ' mapgroup-d/topicgroup ')]" priority="2">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--
     function:	topicref
     param:		none
     return:	self and descendant element or none
     note:		if @print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')]">
    	<xsl:choose>
    		<xsl:when test="@print='no'" >
    		    <xsl:for-each select="descendant-or-self::*[contains(@class,' map/topicref ')]">
    		        <xsl:if test="exists(@href)">
    		            <xsl:call-template name="warningContinue">
    		                <xsl:with-param name="prmMes" select="ahf:replace($stMes1001,('%href','%ohref'),(string(@href),string(@ohref)))"/>
    		            </xsl:call-template>
    		        </xsl:if>
    		    </xsl:for-each>
    		</xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
     function:	topic
     param:		none
     return:	self and descendant element or none
     note:		if @id is pointed from the topicref that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/topic ')]">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="id" as="xs:string" select="concat('#',string(@id))"/>
        <xsl:choose>
            <xsl:when test="exists(index-of($noPrintHrefs,$id)) and empty(index-of($normalHrefs,$id))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1002,('%id','%xtrf'),(string(@id),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="string($prmDitaValFlagStyle)">
                        <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
     function:	link
     param:		none
     return:	self and descendant element or none
     note:		if link@href points to the topicref that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/link ')]">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:choose>
            <xsl:when test="exists(index-of($noPrintHrefs,$href)) and empty(index-of($normalHrefs,$href))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1003,('%href'),($href))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="string($prmDitaValFlagStyle)">
                        <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
     function:	xref
     param:		none
     return:	self and descendant element or none
     note:		if xref@href points to the topic that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')][string(@format) eq 'dita']">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="topicHref" as="xs:string" select="if  (contains($href,'/')) then substring-before($href,'/') else $href"/>
        <xsl:if test="exists(index-of($noPrintHrefs,$topicHref)) and empty(index-of($normalHrefs,$topicHref))" >
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="ahf:replace($stMes1004,('%href'),($href))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    

    <!-- 
     function:	comment template
     param:		none
     return:	comment 
     note:		none
     -->
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- 
     function:	processing-instruction template
     param:		none
     return:	processing-instruction
     note:		
     -->
    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:	required-cleanup template
     param:		none
     return:	none or itself 
     note:		If not output required-cleanup, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')][not($pOutputRequiredCleanup)]"/>
    
    <!-- 
     function:	draft-comment template
     param:		none
     return:	none or itself 
     note:		If not output draft-comment, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/draft-comment ')][not($pOutputDraftComment)]"/>

    <!-- 
     function:	Check $prmAttr has $prmValue
     param:		prmAttr, prmValue
     return:	xs:boolean 
     note:		Return true() if $prmAttr attribute has $prmValue
     -->
    <xsl:function name="ahf:HasAttr" as="xs:boolean">
        <xsl:param name="prmAttr" as="attribute()?"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="empty($prmAttr)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="attr" as="xs:string" select="string($prmAttr)"/>
                <xsl:variable name="attVals" as="xs:string*" select="tokenize($attr,'[\s]+')"/>
                <xsl:sequence select="$prmValue = $attVals"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
