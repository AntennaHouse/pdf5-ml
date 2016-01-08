<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: xref element stylesheet
Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
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

    <!-- 
     function:	xref template
     param:	    prmTopicRef, prmNeedId
     return:	fo:basic-link or fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' topic/xref ')]">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId" tunnel="yes" required="no"  as="xs:boolean" select="true()"/>
        
        <xsl:variable name="xref" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="destAttr" as="attribute()*">
            <xsl:call-template name="getDestinationAttr">
                <xsl:with-param name="prmHref" select="$href"/>
                <xsl:with-param name="prmElem" select="$xref"/>
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($destAttr)">
                <fo:basic-link>
                    <xsl:copy-of select="$destAttr"/>
                    <xsl:call-template name="genXrefContentNodes">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
                        <xsl:with-param name="prmXref"     select="$xref"/>
                        <xsl:with-param name="prmDstAttr"  select="$destAttr"/>
                    </xsl:call-template>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$xref/child::node()"/>
                <!--fo:inline>
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($xref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($xref)"/>
                    <xsl:apply-templates select="$xref/child::node()">
                        <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                    </xsl:apply-templates>
                </fo:inline-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Genrate xref contents
     param:	    prmTopicRef, prmNeedId, prmXref, prmDstAttr
     return:	node()*
     note:		none
     -->
    <xsl:template name="genXrefContentNodes" as="node()*">
        <xsl:param name="prmTopicRef" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId"   required="yes"  as="xs:boolean"/>
        <xsl:param name="prmXref"     required="yes"  as="element()"/>
        <xsl:param name="prmDstAttr"  required="yes"  as="attribute()+"/>

        <xsl:variable name="destElementInf" as="element()*">
            <xsl:call-template name="getInternalDestinationElemInf">
                <xsl:with-param name="prmHref" select="string($prmXref/@href)"/>
                <xsl:with-param name="prmElem" select="$prmXref"/>
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="destElement" as="element()?">
            <xsl:sequence select="$destElementInf[1]"/>
        </xsl:variable>
        
        <xsl:variable name="topicRef" as="element()?">
            <xsl:sequence select="$destElementInf[2]"/>
        </xsl:variable>
        
        <xsl:variable name="destId" as="xs:string">
            <xsl:variable name="internalDestId" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$prmDstAttr[1] instance of attribute(internal-destination)">
                        <xsl:sequence select="string($prmDstAttr[1] treat as attribute(internal-destination))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:sequence select="$internalDestId"/>
        </xsl:variable>

        <xsl:variable name="xrefTitle" as="node()*">
            <xsl:call-template name="getXrefTitle">
                <xsl:with-param name="prmTitleTopicRef" select="$topicRef"/>
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                <xsl:with-param name="prmXref"     select="$prmXref"/>
                <xsl:with-param name="prmDestElement" select="$destElement"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="genXrefAttrAndTitle">
            <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
            <xsl:with-param name="prmNeedId"        select="$prmNeedId"/>
            <xsl:with-param name="prmXref"          select="$prmXref"/>
            <xsl:with-param name="prmDestElement"   select="$destElement"/>
            <xsl:with-param name="prmDestId"        select="$destId"/>
            <xsl:with-param name="prmXrefTitle"     select="$xrefTitle"/>
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Get title of xref
     param:		prmTopicRef, prmDestElement
     return:	fo:inline (title string)
     note:		THIS TEMPLATE DOES NOT GENERATE @id ATTRIBUTE
     -->
    <xsl:template name="getXrefTitle" as="node()*">
        <xsl:param name="prmTitleTopicRef" required="yes" as="element()?"/>
        <xsl:param name="prmTopicRef"      required="yes" as="element()?"/>
        <xsl:param name="prmXref"          required="yes" as="element()"/>
        <xsl:param name="prmDestElement"   required="yes" as="element()?"/>
        
        <xsl:choose>
            <!-- external link or no destination element-->
            <xsl:when test="empty($prmDestElement)">
                <xsl:apply-templates select="$prmXref/child::node()">
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"  tunnel="yes" select="false()"/>
                </xsl:apply-templates>
            </xsl:when>
            
            <!-- topic -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/topic ')]">
                <xsl:variable name="titleMode" select="ahf:getTitleMode($prmTitleTopicRef,$prmDestElement)"/>
                <xsl:variable name="topicTitlePrefix" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$titleMode eq $cSquareBulletTitleMode">
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'Level4_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$titleMode eq $cRoundBulletTitleMode">
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$pAddNumberingTitlePrefix">
                            <xsl:call-template name="genTitlePrefix">
                                <xsl:with-param name="prmTopicRef" select="$prmTitleTopicRef"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="topicTitleBody" as="node()*">
                    <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string($topicTitlePrefix)">
                        <fo:inline>
                            <xsl:value-of select="$topicTitlePrefix"/>
                            <xsl:text>&#x00A0;</xsl:text>
                        </fo:inline>
                        <xsl:copy-of select="$topicTitleBody"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$topicTitleBody"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/section ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="sectionTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$sectionTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                                select="ahf:replace($stMes031,('%id','%file'),(string($prmDestElement/@id),string($prmDestElement/@xtrf)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- example -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/example ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="exampleTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$exampleTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                                select="ahf:replace($stMes032,('%id','%file'),(string($prmDestElement/@id),string($prmDestElement/@xtrf)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- ol/li -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <!-- Prefix of ol -->
                <xsl:variable name="olNumberFormat" as="xs:string*">
                    <xsl:variable name="olNumberFormats" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'Ol_Number_Formats'"/>
                            <xsl:with-param name="prmElem" select="$prmDestElement"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:for-each select="tokenize($olNumberFormats, '[\s]+')">
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="olFormat" as="xs:string" select="ahf:getOlNumberFormat($prmDestElement,$olNumberFormat)"/>
                <fo:inline>
                    <xsl:number format="{$olFormat}" 
                        value="count($prmDestElement/preceding-sibling::*[contains(@class, ' topic/li ')][not(contains(@class,' task/stepsection '))]) + 1"/>
                </fo:inline>
            </xsl:when>
            
            <!-- table -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="tableTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <xsl:variable name="tableTitleSuffix"
                            select="ahf:getTableTitlePrefix($prmTitleTopicRef,$prmDestElement)" 
                            as="xs:string"/>
                        
                        <fo:inline>
                            <xsl:value-of select="$tableTitleSuffix"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$tableTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                select="ahf:replace($stMes033,('%id','%file'),(string($prmDestElement/@id),string($prmDestElement/@xtrf)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- fig -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fig ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="figTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <xsl:variable name="figTitleSuffix"
                            select="ahf:getFigTitlePrefix($prmTitleTopicRef,$prmDestElement)" 
                            as="xs:string"/>
                        
                        <fo:inline>
                            <xsl:value-of select="$figTitleSuffix"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$figTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                select="ahf:replace($stMes034,('%id','%file'),(string($prmDestElement/@id),string($prmDestElement/@xtrf)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- equation-block -->
            <xsl:when test="$prmDestElement[contains(@class, ' equation-d/equation-block ')]">
                <xsl:variable name="equationNumber" as="element()?" select="($prmDestElement/*[contains(@class, ' equation-d/equation-number ')])[1]"/>
                <xsl:variable name="equtionNumberResult" as="node()*">
                    <xsl:choose>
                        <xsl:when test="$pNumberEquationBlockUnconditionally and empty($equationNumber)">
                            <xsl:variable name="autoEquationNumber" as="xs:string">
                                <xsl:call-template name="ahf:getAutoEquationNumber">
                                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTitleTopicRef"/>
                                    <xsl:with-param name="prmEquationNumber" select="$prmDestElement"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Ref_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:value-of select="$autoEquationNumber"/>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$prmDestElement/*[contains(@class, ' equation-d/equation-number ')]">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Ref_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$equationNumber"/>
                            </xsl:call-template>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$equationNumber"/>
                            </xsl:call-template>
                            <xsl:choose>
                                <xsl:when test="ahf:isAutoEquationNumber($equationNumber)">
                                    <xsl:variable name="autoEquationNumber" as="xs:string">
                                        <xsl:call-template name="ahf:getAutoEquationNumber">
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTitleTopicRef"/>
                                            <xsl:with-param name="prmEquationNumber" select="$equationNumber"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:value-of select="$autoEquationNumber"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$equationNumber" mode="GET_CONTENTS"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Equation_Number_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$equationNumber"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- equation-block without equation-number -->
                            <xsl:apply-templates select="$prmXref/node()">
                                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>    
                </xsl:variable>
                <fo:inline>
                    <xsl:copy-of select="$equtionNumberResult"/>
                </fo:inline>
            </xsl:when>
            
            <!-- fn -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fn ')]">
                <xsl:variable name="fnTitle" as="xs:string" select="ahf:getFootnotePrefix($prmDestElement, $prmTitleTopicRef)"/>
                <fo:inline>
                    <xsl:value-of select="$fnTitle"/>
                </fo:inline>
            </xsl:when>
            
            <!-- Other elements that have title -->
            <xsl:when test="$prmDestElement[child::*[contains(@class, ' topic/title ')]]">
                <xsl:variable name="title" as="node()*">
                    <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                </xsl:variable>
                <fo:inline>
                    <xsl:copy-of select="$title"/>
                </fo:inline>
            </xsl:when>
            
            <!-- Others -->
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes"
                        select="ahf:replace($stMes035,('%id','%elem','%file'),(string($prmDestElement/@id),name($prmDestElement),string($prmDestElement/@xtrf)))"/>
                </xsl:call-template>
                <xsl:variable name="title" as="node()*">
                    <xsl:apply-templates select="$prmDestElement" mode="TEXT_ONLY"/>
                </xsl:variable>
                <fo:inline>
                    <xsl:copy-of select="$title"/>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- 
     function:	Generate attribute and contents for fo:basic-link
     param:		prmTopicRef, prmNeedId, prmXref, prmDestElement, prmDestId, prmXrefTitle
     return:	FO objects
     note:		This template generates attribute() then content node (text() or other inline element).
                Do not generate ant content node for fo:basic-link before calling this template.
     -->
    <xsl:template name="genXrefAttrAndTitle" as="node()*">
        <xsl:param name="prmTopicRef"      as="element()?" required="yes"/>
        <xsl:param name="prmNeedId"        as="xs:boolean" required="yes"/>
        <xsl:param name="prmXref"          as="element()"  required="yes"/>
        <xsl:param name="prmDestElement"   as="element()?" required="yes"/>
        <xsl:param name="prmDestId"        as="xs:string"  required="yes"/>
        <xsl:param name="prmXrefTitle"     as="node()*"    required="yes"/>
        
        <xsl:choose>
            <!-- external link -->
            <xsl:when test="empty($prmDestElement)">
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of  select="$prmXrefTitle"/>
            </xsl:when>
            
            <!-- topic -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/topic ')]">
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <fo:inline>
                    <xsl:copy-of  select="$prmXrefTitle"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            
            <!-- section/example -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/section ') or contains(@class, ' topic/example ')]">
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of  select="$prmXrefTitle"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
                <fo:page-number-citation ref-id="{$prmDestId}"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- ol/li: Xref link color does not apply for ol/li and does not use fo:pagenumber-citation. -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of select="$prmXrefTitle"/>
            </xsl:when>
            
            <!-- table/fig: Same as section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ') or contains(@class, ' topic/fig ')]">
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of  select="$prmXrefTitle"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
                <fo:page-number-citation ref-id="{$prmDestId}"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- fn: Apply fn style -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fn ')]">
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsFnPrefix')"/>
                <xsl:value-of select="$prmXrefTitle"/>
            </xsl:when>
            
            <!-- Other elements that have title: same as section -->
            <xsl:when test="$prmDestElement[child::*[contains(@class, ' topic/title ')]]">
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of  select="$prmXrefTitle"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
                <fo:page-number-citation ref-id="{$prmDestId}"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                    <xsl:with-param name="prmElem" select="$prmXref"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- Others -->
            <xsl:otherwise>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of select="$prmXrefTitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        function:	desc template
        param:	    
        return:	    only call descendant template
        note:		This template is obsolute. (It will be never called)
        [Other descs]
        fig/desc:     dita2fo_bodyelements.xsl
        object/desc:  Ignored.
        table/desc:   dita2fo_tableelements.xsl
        link/desc:    Ignored.
        linklist/desc:Ignored.
    -->
    <xsl:template match="*[contains(@class, ' topic/xref ')]/*[contains(@class, ' topic/desc ')]">
        <xsl:apply-templates>
        </xsl:apply-templates>
    </xsl:template>

</xsl:stylesheet>