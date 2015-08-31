<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
@href Attribute Utility Templates
**************************************************************
File Name : dita2fo_href_util.xsl
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
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >

    <!-- 
     function:	Return that given href is local or not.
     param:		prmHref: @href
     return:	xs:boolean
     note:		
    -->
    <xsl:function name="ahf:isLocalHref" as="xs:boolean">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:sequence select="starts-with($prmHref,'#')"/>
    </xsl:function>

    <!-- 
     function:	Get fo:basick-link/@internal-destination, external-destination attribute
                from @href attribute
     param:		prmHref: @href
                prmElem: Relevant element 
     return:	attribute()*
     note:		
    -->
    <xsl:template name="getDestinationAttr" as="attribute()*">
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:param name="prmTopicRef" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="not(string($prmHref))">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="ahf:isLocalHref($prmHref)">
                <xsl:call-template name="getInternalDestinationAttr">
                    <xsl:with-param name="prmHref" select="$prmHref"/>
                    <xsl:with-param name="prmElem" select="$prmElem"/>
                    <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getExternalDestinationAttr">
                    <xsl:with-param name="prmHref" select="$prmHref"/>
                    <xsl:with-param name="prmElem" select="$prmElem"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Get fo:basick-link/internal-destination attribute
     param:		prmHref: @href
                prmElem: Relevant element 
     return:	attribute()*
     note:		
    -->
    <xsl:template name="getInternalDestinationAttr" as="attribute()*">
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:param name="prmTopicRef" as="element()?" required="yes"/>
        <xsl:variable name="destElementId" as="xs:string" select="substring-after($prmHref,'/')"/>
        <xsl:variable name="topicId" as="xs:string" select="if (string($destElementId)) then substring-before(substring-after($prmHref,'#'), '/') else (substring-after($prmHref,'#'))"/>
        <xsl:variable name="topicElement" as="element()?" select="key('topicById', $topicId,$root)[1]"/>
        <xsl:variable name="destElement" as="element()?" select="if (string($destElementId) and exists($topicElement)) then key('elementById',$destElementId,$topicElement)[1] else ()"/>
        <xsl:variable name="localTopicId" as="xs:string" select="string($prmElem/ancestor::*[contains(@class,' topic/topic ')][last()]/@id)"/>
        <xsl:variable name="topicRef" as="element()?" select="if ($topicId eq $localTopicId) then $prmTopicRef else ahf:getTopicRef($topicElement)"/>
        <xsl:choose>
            <xsl:when test="empty($topicRef)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes072,('%href','%file'),(string($prmElem/@ohref),string($prmElem/@xtrf)))"/>
                </xsl:call-template>
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="exists($destElement)">
                <xsl:variable name="destIdAtr" as="attribute()*" select="ahf:getIdAtts($destElement,$topicRef,true())" />
                <xsl:variable name="destId"  as="xs:string" select="string($destIdAtr[1])"/>
                <xsl:attribute name="internal-destination" select="$destId"/>
            </xsl:when>
            <xsl:when test="exists($topicElement)">
                <xsl:variable name="destIdAtr" as="attribute()*" select="ahf:getIdAtts($topicElement,$topicRef,true())"/>
                <xsl:variable name="destId" as="xs:string" select="string($destIdAtr[1])"/>
                <xsl:attribute name="internal-destination" select="$destId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes"
                        select="ahf:replace($stMes030,('%h','%file'),(string($prmElem/@ohref),string($prmElem/@xtrf)))"/>
                </xsl:call-template>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Get fo:basick-link/external-destination attribute
     param:		prmHref: @href
                prmElem: Relevant element 
     return:	attribute()?
     note:		
    -->
    <xsl:template name="getExternalDestinationAttr" as="attribute()*">
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:variable name="isLinkToInsidePdf" as="xs:boolean" select="matches($prmHref,'(\.PDF#|\.pdf#)')"/>
        <xsl:variable name="modifiedHref" as="xs:string" select="replace($prmHref,'(\.PDF#|\.pdf#)','$1nameddest=')"/>
        <xsl:variable name="url" as="xs:string" select="concat('url(',$modifiedHref,')')"/>
        <xsl:attribute name="external-destination" select="$url"/>
        <xsl:if test="$isLinkToInsidePdf">
            <xsl:attribute name="axf:action-type" select="'gotor'"/>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	Get destination element from @href
     param:		prmHref: @href
                prmElem: Relevant element 
     return:	element()*
     note:		
    -->
    <xsl:template name="getInternalDestinationElemInf" as="element()*">
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:param name="prmTopicRef" as="element()?" required="yes"/>
        <xsl:variable name="destElementId" as="xs:string" select="substring-after($prmHref,'/')"/>
        <xsl:variable name="topicId" as="xs:string" select="if (string($destElementId)) then substring-before(substring-after($prmHref,'#'), '/') else (substring-after($prmHref,'#'))"/>
        <xsl:variable name="topicElement" as="element()?" select="key('topicById', $topicId,$root)[1]"/>
        <xsl:variable name="destElement" as="element()?" select="if (string($destElementId) and exists($topicElement)) then key('elementById',$destElementId,$topicElement)[1] else ()"/>
        <xsl:variable name="localTopicId" as="xs:string" select="string($prmElem/ancestor::*[contains(@class,' topic/topic ')][last()]/@id)"/>
        <xsl:variable name="topicRef" as="element()?" select="if ($topicId eq $localTopicId) then $prmTopicRef else ahf:getTopicRef($topicElement)"/>
        <xsl:choose>
            <xsl:when test="not(ahf:isLocalHref($prmHref))">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="empty($topicRef)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes072,('%href','%file'),(string($prmElem/@ohref),string($prmElem/@xtrf)))"/>
                </xsl:call-template>
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="exists($destElement)">
                <xsl:sequence select="$destElement"/>
                <xsl:sequence select="$topicRef"/>
            </xsl:when>
            <xsl:when test="exists($topicElement)">
                <xsl:sequence select="$topicElement"/>
                <xsl:sequence select="$topicRef"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes"
                        select="ahf:replace($stMes030,('%h','%file'),(string($prmElem/@ohref),string($prmElem/@xtrf)))"/>
                </xsl:call-template>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>