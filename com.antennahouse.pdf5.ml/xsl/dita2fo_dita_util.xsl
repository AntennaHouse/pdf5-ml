<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
Utility Templates
**************************************************************
File Name : dita2fo_dita_util.xsl
**************************************************************
Copyright © 2009 2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->

<xsl:stylesheet version="2.0" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
 	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 	xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 	xmlns:ahd="http://www.antennahouse.com/names/XSLT/Debugging"
 	exclude-result-prefixes="xs ahf" >

    <!--
    ===============================================
     DITA Utility Templates
    ===============================================
    -->
    
    <!-- 
      ============================================
         toc utility
      ============================================
    -->
    <!--
    function: isToc Utility
    param: prmElement
    note: Return boolena that parameter should add toc or not.
    -->
    <xsl:function name="ahf:isToc" as="xs:boolean">
        <xsl:param name="prmValue" as ="element()"/>
        
        <xsl:sequence select="not(ahf:isTocNo($prmValue))"/>
    </xsl:function>
    
    <!-- 
     function:	Check @toc="no" 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isTocNo" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:choose>
            <xsl:when test="string($prmTopicRef/@toc) eq 'no'">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Get topic from topicref 
     param:		prmTopicRef
     return:	xs:element?
     note:		
     -->
    <xsl:function name="ahf:getTopicFromTopicRef" as="element()?">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($id)) then key('topicById', $id, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>
    
    <xsl:function name="ahf:getTopicFromLink" as="element()?">
        <xsl:param name="prmLink" as="element()"/>
        <xsl:sequence select="ahf:getTopicFromTopicRef($prmLink)"/>
    </xsl:function>

    <!-- 
     function:	Get topic from href 
     param:		prmHref
     return:	xs:element?
     note:		
     -->
    <xsl:function name="ahf:getTopicFromHref" as="element()?">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($prmHref)) then key('topicById', $prmHref, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>

    <!-- 
     function:	Get topicref from topic
     param:		prmTopicContent
     return:	topicref
     note:		
     -->
    <xsl:function name="ahf:getTopicRef" as="element()?">
        <xsl:param name="prmTopic" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="empty($prmTopic)">
                <!-- invalid parameter -->
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="not(contains($prmTopic/@class, ' topic/topic '))">
                <!-- It is not a topic! -->
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="id" select="$prmTopic/@id" as="xs:string"/>
                <xsl:variable name="topicRef" select="key('topicrefByHref', concat('#',$id), $map)[1]" as="element()?"/>
                <xsl:choose>
                    <xsl:when test="exists($topicRef)">
                        <xsl:sequence select="$topicRef"/>
                    </xsl:when>
                    <xsl:when test="$prmTopic/ancestor::*[contains(@class, ' topic/topic ')]">
                        <!-- search ancestor -->
                        <xsl:sequence select="ahf:getTopicRef($prmTopic/ancestor::*[contains(@class, ' topic/topic ')][position()=last()])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- not found -->
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate topic file name as @ahd:topic attribute for debugging
     param:		prmTopic
     return:	attribute()
     note:		
     -->
    <xsl:template name="ahf:getTopicFileNameAsAttr" as="attribute()">
        <xsl:sequence select="ahf:getTopicFileNameAsAttr(.)"/>
    </xsl:template>
    
    <xsl:function name="ahf:getTopicFileNameAsAttr" as="attribute()">
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:variable name="topicFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash(string($prmTopic/@xtrf)),'/')"/>
        <xsl:attribute name="ahd:topic-file" select="$topicFileName"/>
    </xsl:function>

    <!-- 
     function:	Return topicref is for cover 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isCoverTopicRef" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:variable name="outputClass" as="xs:string" select="if (exists($prmTopicRef)) then string($prmTopicRef/@outputclass) else ''"/>
        <xsl:sequence select="matches($outputClass,'cover[1-4]')"/>
    </xsl:function>
    
    <!-- 
     function:	topicref count template
     param:		prmTopicRef
     return:	topicref count that have same @href
     note:		none
    -->
    <xsl:function name="ahf:countTopicRef" as="xs:integer">
        <xsl:param name="prmTopicRef" as="element()"/>
        
        <xsl:variable name="href" select="string($prmTopicRef/@href)" as="xs:string"/>
        <xsl:variable name="topicRefCount" as="xs:integer">
            <xsl:number select="$prmTopicRef"
                level="any"
                count="*[contains(@class,' map/topicref ')][string(@href) eq $href]"
                from="*[contains(@class,' map/map ')]"
                format="1"/>
        </xsl:variable>
        <xsl:sequence select="$topicRefCount"/>
    </xsl:function>

    <!-- 
     function:	Get font-family attribute considering xml:lang
     param:		prmAttsetName, prmElem
     return:	attribute()*
     note:		none
    -->
    <xsl:function name="ahf:getFontFamlyWithLang" as="attribute()*">
        <xsl:param name="prmAttrsetName" as="xs:string"/>
        <xsl:param name="prmElem" as="element()"/>
        <xsl:call-template name="getAttributeSetWithLang">
            <xsl:with-param name="prmAttrSetName" select="$prmAttrsetName"/>
            <xsl:with-param name="prmElem" select="$prmElem"/>
            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
            <xsl:with-param name="prmDoInherit" select="true()"/>
        </xsl:call-template>
    </xsl:function>
    

    <!-- end of stylesheet -->
</xsl:stylesheet>
