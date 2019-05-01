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
     param:       prmTitleTopicRef: topicref that corresponds the xref target
                  prmTopicRef: topicref that corrresponds xref
                  prmXref: xref element itself
                  prmDestElement: target of the xref
     return:      fo:inline (title string)
     note:		THIS TEMPLATE DOES NOT GENERATE @id ATTRIBUTE
                  
     -->
    <xsl:template name="getXrefTitle" as="node()*">
        <xsl:param name="prmTitleTopicRef" required="yes" as="element()?"/>
        <xsl:param name="prmTopicRef"      required="yes" as="element()?"/>
        <xsl:param name="prmXref"          required="yes" as="element()"/>
        <xsl:param name="prmDestElement"   required="yes" as="element()?"/>
        
        <xsl:variable name="hasUserText" as="xs:boolean" select="exists($prmXref/node()[1][self::processing-instruction(ditaot)][string(.) eq 'user-text'])"/>
        
        <xsl:choose>
            <!-- external link or no destination element
                 Added  user text handling.
                 2019-05-01 t.makita
              -->
            <xsl:when test="empty($prmDestElement)">
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$prmXref/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- topic
                 Added $topicTitlePrefix/Suffix and user text handling.
                 2019-05-01 t.makita
              -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/topic ')]">
                <xsl:variable name="titleMode" select="ahf:getTitleMode($prmTitleTopicRef,$prmDestElement)"/>
                <xsl:variable name="topicTitleHeading" as="xs:string">
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
                <xsl:variable name="topicTitlePrefix" as="text()?">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Topic_Title_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="topicTitleSuffix" as="text()?">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Topic_Title_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:when test="string($topicTitleHeading)">
                        <fo:inline>
                            <xsl:copy-of select="$topicTitlePrefix"/>
                            <xsl:value-of select="$topicTitleHeading"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$topicTitleBody"/>
                            <xsl:copy-of select="$topicTitleSuffix"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:inline>
                            <xsl:copy-of select="$topicTitlePrefix"/>
                            <xsl:copy-of select="$topicTitleBody"/>
                            <xsl:copy-of select="$topicTitleSuffix"/>
                        </fo:inline>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/section ')]">
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="sectionTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <xsl:variable name="sectionTitlePrefix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Section_Title_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="sectionTitleSuffix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Section_Title_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:copy-of select="$sectionTitlePrefix"/>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$sectionTitle"/>
                            <xsl:copy-of select="$sectionTitleSuffix"/>
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
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="exampleTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <xsl:variable name="exampleTitlePrefix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Example_Title_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="exampleTitleSuffix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Example_Title_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:copy-of select="$exampleTitlePrefix"/>
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$exampleTitle"/>
                            <xsl:copy-of select="$exampleTitleSuffix"/>
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
            
            <!-- step/substep -->
            <xsl:when test="$prmDestElement[ahf:seqContains(@class, (' task/step ',' task/substep '))]">
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Prefix of step: "step" -->
                        <xsl:variable name="stepHeading" as="xs:string">
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'Xref_Step_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmDestElement"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="stepNumberFormat" as="xs:string+">
                            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                                <xsl:with-param name="prmVarName" select="'Step_Number_Formats'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$prmDestElement[contains(@class, ' task/step ')]">
                                <xsl:variable name="numberFormat" select="ahf:getOlNumberFormat($prmDestElement,$stepNumberFormat)" as="xs:string"/>
                                <fo:inline>
                                    <xsl:copy-of select="$stepHeading"/>
                                    <xsl:number format="{$numberFormat}" value="ahf:getStepNumber($prmDestElement)"/>
                                </fo:inline>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="stepNumberFormat" select="ahf:getOlNumberFormat($prmDestElement/parent::*,$stepNumberFormat)" as="xs:string"/>
                                <xsl:variable name="subStepNumberFormat" select="ahf:getOlNumberFormat($prmDestElement,$stepNumberFormat)" as="xs:string"/>
                                <xsl:variable name="stepSubstepSeparator" as="text()?">
                                    <xsl:call-template name="getVarValueWithLangAsText">
                                        <xsl:with-param name="prmVarName" select="'Xref_Step_Substep_Separator'"/>
                                        <xsl:with-param name="prmElem" select="$prmDestElement"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <fo:inline>
                                    <xsl:copy-of select="$stepHeading"/>
                                    <xsl:number format="{$stepNumberFormat}" value="ahf:getStepNumber($prmDestElement/parent::*)"/>
                                    <xsl:copy-of select="$stepSubstepSeparator"/>
                                    <xsl:number format="{$subStepNumberFormat}" value="ahf:getStepNumber($prmDestElement)"/>
                                </fo:inline>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- ol/li -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:otherwise>
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
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- table -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ')]">
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="tableTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <xsl:variable name="tableTitleHeading"
                            select="ahf:getTableTitlePrefix($prmTitleTopicRef,$prmDestElement)" 
                            as="xs:string"/>
                        <xsl:variable name="tableTitlePrefix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Table_Title_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="tableTitleSuffix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Table_Title_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:copy-of select="$tableTitlePrefix"/>
                            <xsl:value-of select="$tableTitleHeading"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$tableTitle"/>
                            <xsl:copy-of select="$tableTitleSuffix"/>
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
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="figTitle" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <xsl:variable name="figTitleHeading"
                            select="ahf:getFigTitlePrefix($prmTitleTopicRef,$prmDestElement)" 
                            as="xs:string"/>
                        <xsl:variable name="figTitlePrefix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Fig_Title_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="figTitleSuffix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Fig_Title_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <fo:inline>
                            <xsl:copy-of select="$figTitlePrefix"/>
                            <xsl:value-of select="$figTitleHeading"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$figTitle"/>
                            <xsl:copy-of select="$figTitleSuffix"/>
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
                        <xsl:when test="$hasUserText">
                            <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                        </xsl:when>
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
                            <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
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
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="title" as="node()*">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        <xsl:variable name="otherTitlePrefix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Other_Title_Prefix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="otherTitleSuffix" as="text()?">
                            <xsl:call-template name="getVarValueWithLangAsText">
                                <xsl:with-param name="prmVarName" select="'Xref_Other_Title_Suffix'"/>
                                <xsl:with-param name="prmElem" select="$prmXref"/>
                            </xsl:call-template>
                        </xsl:variable>
                         <fo:inline>
                            <xsl:copy-of select="$otherTitlePrefix"/>
                            <xsl:copy-of select="$title"/>
                            <xsl:copy-of select="$otherTitleSuffix"/>
                        </fo:inline>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- Others: Adopt the content of xref itself if user supplied text exists.
             -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$hasUserText">
                        <xsl:apply-templates select="$prmXref" mode="GET_CONTENTS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                select="ahf:replace($stMes035,('%id','%elem','%file'),(string($prmDestElement/@id),name($prmDestElement),string($prmDestElement/@xtrf)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
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
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToTopicOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <fo:inline>
                    <xsl:if test="($opt = ($optXrefToTopicTitleAndPage,$optXrefToTopicTitleOnly)) or empty($opt)">
                        <xsl:copy-of  select="$prmXrefTitle"/>
                    </xsl:if>
                    <xsl:if test="($opt = ($optXrefToTopicTitleAndPage,$optXrefToTopicPageOnly)) or empty($opt)">
                        <xsl:call-template name="getVarValueWithLangAsText">
                            <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                            <xsl:with-param name="prmElem" select="$prmXref"/>
                        </xsl:call-template>
                        <fo:page-number-citation ref-id="{$prmDestId}"/>
                        <xsl:call-template name="getVarValueWithLangAsText">
                            <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                            <xsl:with-param name="prmElem" select="$prmXref"/>
                        </xsl:call-template>
                    </xsl:if>    
                </fo:inline>
            </xsl:when>
            
            <!-- section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/section ')]">
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToSectionOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="($opt = ($optXrefToSectionTitleAndPage,$optXrefToSectionTitleOnly)) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="($opt = ($optXrefToSectionTitleAndPage,$optXrefToSectionPageOnly)) or empty($opt)">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>

            <!-- example -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/example ')]">
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToExampleOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="($opt = ($optXrefToExampleTitleAndPage,$optXrefToExampleTitleOnly)) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="($opt = ($optXrefToExampleTitleAndPage,$optXrefToExamplePageOnly)) or empty($opt)">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>

            <!-- steps/step, substep: Xref link color does not apply. -->
            <xsl:when test="$prmDestElement[contains(@class, ' task/step ')][parent::*[contains(@class,' task/substep ')]]">
  No        <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToStepOption($prmXref)"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="($opt = ($optXrefToStepNumberAndPage,$optXrefToStepNumberOnly)) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="($opt = ($optXrefToStepNumberAndPage))">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>

            <!-- ol/li: Xref link color does not apply for ol/li. -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToLiOption($prmXref)"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="($opt = ($optXrefToLiNumberAndPage,$optXrefToLiNumberOnly)) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="($opt = ($optXrefToLiNumberAndPage))">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            
            <!-- table/fig: Same as section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ') or contains(@class, ' topic/fig ')]">
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToTableOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="$opt = ($optXrefToTableTitleAndPage,$optXrefToTableTitleOnly) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="$opt = ($optXrefToTableTitleAndPage,$optXrefToTablePageOnly) or empty($opt)">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            
            <!-- fn: Apply fn style. No output options. -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fn ')]">
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsFnPrefix')"/>
                <xsl:value-of select="$prmXrefTitle"/>
            </xsl:when>
            
            <!-- Other elements that have title: same as section -->
            <xsl:when test="$prmDestElement[child::*[contains(@class, ' topic/title ')]]">
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToOtherOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="$opt = ($optXrefToOtherTitleAndPage,$optXrefToOtherTitleOnly) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="$opt = ($optXrefToOtherTitleAndPage,$optXrefToOtherPageOnly) or empty($opt)">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            
            <!-- Others -->
            <xsl:otherwise>
                <xsl:variable name="opt" as="xs:string" select="ahf:getXrefToOtherOption($prmXref)"/>
                <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                <xsl:if test="$opt = ($optXrefToOtherTitleAndPage,$optXrefToOtherTitleOnly) or empty($opt)">
                    <xsl:copy-of  select="$prmXrefTitle"/>
                </xsl:if>
                <xsl:if test="$opt = ($optXrefToOtherTitleAndPage,$optXrefToOtherPageOnly) or empty($opt)">
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$prmDestId}"/>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Xref_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmXref"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        function:	desc template
        param:	    
        return:	    only call descendant template
        note:		This template is obsolete. (It will be never called)
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


    <!-- 
        function:	get xref to topic output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToTopicTitleAndPage" as="xs:string" select="'title-page'"/>
    <xsl:variable name="optXrefToTopicTitleOnly" as="xs:string" select="'title-only'"/>
    <xsl:variable name="optXrefToTopicPageOnly" as="xs:string" select="'page-only'"/>
    <xsl:function name="ahf:getXrefToTopicOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTopicTitleAndPage)">
                <xsl:sequence select="$optXrefToTopicTitleAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTopicTitleOnly)">
                <xsl:sequence select="$optXrefToTopicTitleOnly"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTopicPageOnly)">
                <xsl:sequence select="$optXrefToTopicPageOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        function:	get xref to section output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToSectionTitleAndPage" as="xs:string" select="'title-page'"/>
    <xsl:variable name="optXrefToSectionTitleOnly" as="xs:string" select="'title-only'"/>
    <xsl:variable name="optXrefToSectionPageOnly" as="xs:string" select="'page-only'"/>
    <xsl:function name="ahf:getXrefToSectionOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToSectionTitleAndPage)">
                <xsl:sequence select="$optXrefToSectionTitleAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToSectionTitleOnly)">
                <xsl:sequence select="$optXrefToSectionTitleOnly"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToSectionPageOnly)">
                <xsl:sequence select="$optXrefToSectionPageOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        function:	get xref to example output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToExampleTitleAndPage" as="xs:string" select="'title-page'"/>
    <xsl:variable name="optXrefToExampleTitleOnly" as="xs:string" select="'title-only'"/>
    <xsl:variable name="optXrefToExamplePageOnly" as="xs:string" select="'page-only'"/>
    <xsl:function name="ahf:getXrefToExampleOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToExampleTitleAndPage)">
                <xsl:sequence select="$optXrefToExampleTitleAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToExampleTitleOnly)">
                <xsl:sequence select="$optXrefToExampleTitleOnly"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToExamplePageOnly)">
                <xsl:sequence select="$optXrefToExamplePageOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        function:	get xref to step/substep output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToStepNumberAndPage" as="xs:string" select="'number-page'"/>
    <xsl:variable name="optXrefToStepNumberOnly" as="xs:string" select="'number-only'"/>
    <xsl:function name="ahf:getXrefToStepOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToStepNumberAndPage)">
                <xsl:sequence select="$optXrefToStepNumberAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToStepNumberOnly)">
                <xsl:sequence select="$optXrefToStepNumberOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        function:	get xref to li output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToLiNumberAndPage" as="xs:string" select="'number-page'"/>
    <xsl:variable name="optXrefToLiNumberOnly" as="xs:string" select="'number-only'"/>
    <xsl:function name="ahf:getXrefToLiOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToLiNumberAndPage)">
                <xsl:sequence select="$optXrefToLiNumberAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToLiNumberOnly)">
                <xsl:sequence select="$optXrefToLiNumberOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        function:	get xref to fig/table output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToTableTitleAndPage" as="xs:string" select="'title-page'"/>
    <xsl:variable name="optXrefToTableTitleOnly" as="xs:string" select="'title-only'"/>
    <xsl:variable name="optXrefToTablePageOnly" as="xs:string" select="'page-only'"/>
    <xsl:function name="ahf:getXrefToTableOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTableTitleAndPage)">
                <xsl:sequence select="$optXrefToTableTitleAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTableTitleOnly)">
                <xsl:sequence select="$optXrefToTableTitleOnly"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToTablePageOnly)">
                <xsl:sequence select="$optXrefToTablePageOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        function:	get xref to other elements output option
        param:	   prmXref 
        return:	  xs:string
        note:		Customizing this function make it possible to specify your own xref output option values.
    -->
    <xsl:variable name="optXrefToOtherTitleAndPage" as="xs:string" select="'title-page'"/>
    <xsl:variable name="optXrefToOtherTitleOnly" as="xs:string" select="'title-only'"/>
    <xsl:variable name="optXrefToOtherPageOnly" as="xs:string" select="'page-only'"/>
    <xsl:function name="ahf:getXrefToOtherOption" as="xs:string*">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToOtherTitleAndPage)">
                <xsl:sequence select="$optXrefToOtherTitleAndPage"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToOtherTitleOnly)">
                <xsl:sequence select="$optXrefToOtherTitleOnly"/>
            </xsl:when>
            <xsl:when test="ahf:hasOutputClassValue($prmXref,$optXrefToOtherPageOnly)">
                <xsl:sequence select="$optXrefToOtherPageOnly"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

</xsl:stylesheet>