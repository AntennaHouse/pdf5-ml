<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Programming elements stylesheet
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	apiname template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/apiname ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsApiName'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' pr-d/apiname ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	codeblock template
     param:	    
     return:	fo:block
     note:		
     -->
    <xsl:template match="*[contains(@class, ' pr-d/codeblock ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsCodeBlock'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' pr-d/codeblock ')]" priority="2">
        <xsl:variable name="codeBlockAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:block>
            <xsl:copy-of select="$codeBlockAttr"/>
            <xsl:copy-of select="ahf:getDisplayAtts(.,$codeBlockAttr)"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	codeph template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/codeph ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsCodePh'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' pr-d/codeph ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	option template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/option ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsOption'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' pr-d/option ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	paramname template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/parmname ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsParamName'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' pr-d/parmname ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	parml template
     param:	    
     return:	fo:wrapper
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/parml ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsParml'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' pr-d/parml ')]" priority="2">
        <xsl:variable name="doCompact" select="string(@compact) eq 'yes'" as="xs:boolean"/>
        <fo:wrapper>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmDoCompact"  select="$doCompact"/>
            </xsl:apply-templates>
        </fo:wrapper>
    </xsl:template>
    
    <!-- 
     function:	plentry template
     param:	    prmDoCompact
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/plentry ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsPlEntry'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/plentry ')]" priority="2">
        <xsl:param name="prmDoCompact" required="yes" as="xs:boolean"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <!-- apply compact spacing -->
            <xsl:if test="$prmDoCompact">
                <xsl:variable name="plCompactRatio" as="xs:double">
                    <xsl:call-template name="getVarValueWithLangAsDouble">
                        <xsl:with-param name="prmVarName" select="'Pl_Compact_Ratio'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="plCompactAttrName" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Pl_Compact_Attr'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="plCompactAttrVal" as="xs:string">
                    <xsl:call-template name="getAttributeValueWithLang">
                        <xsl:with-param name="prmAttrSetName" as="xs:string*">
                            <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                        </xsl:with-param>
                        <xsl:with-param name="prmAttrName" select="$plCompactAttrName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="{$plCompactAttrName}" 
                    select="ahf:getPropertyRatio($plCompactAttrVal,$plCompactRatio)"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	pt template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/pt ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsPt'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' pr-d/pt ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	pd template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/pd ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsPd'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' pr-d/pd ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	synph template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/synph ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	syntaxdiagram template
     param:	    
     return:	fo:block
     note:		Syntaxdiagram belongs figure.
     -->
    <xsl:template match="*[contains(@class, ' pr-d/syntaxdiagram ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSyntaxDiagram'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]" priority="2">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmNeedId" tunnel="yes" required="no" as="xs:boolean" select="true()"/>

        <xsl:variable name="syntaxDiagramAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:block>
            <xsl:copy-of select="$syntaxDiagramAttr"/>
            <xsl:copy-of select="ahf:getDisplayAtts(.,$syntaxDiagramAttr)"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:if test="empty(@id) and $prmNeedId">
                <xsl:attribute name="id" select="ahf:generateId(.,$prmTopicRef)"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[not(contains(@class,' topic/title '))]"/>
            <xsl:if test="descendant::*[contains(@class,' pr-d/synnote ')]">
                <xsl:call-template name="outputSynNote"/>
            </xsl:if>
        </fo:block>
        <!-- process title last -->
        <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
    </xsl:template>
    
    <!-- 
     function:	Output synnote
     param:	    prmTopicRef, prmNeedId
     return:	fo:list-block
     note:		current is syntaxdiagram.
     -->
    <xsl:template name="outputSynNote">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmNeedId" tunnel="yes" required="no" as="xs:boolean" select="true()"/>
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsSynNoteListBlock'"/>
            </xsl:call-template>
            <xsl:for-each select="descendant::*[contains(@class, ' pr-d/synnote ')]">
                <xsl:variable name="synnote" select="."/>
                <fo:list-item>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsSynNoteLi'"/>
                    </xsl:call-template>
                    <xsl:if test="position() eq 1">
                        <xsl:attribute name="space-before" select="'0mm'"/>
                    </xsl:if>
                    <fo:list-item-label end-indent="label-end()"> 
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsSynNoteLabel'"/>
                            </xsl:call-template>
                            <xsl:choose>
                                <xsl:when test="string(normalize-space($synnote/@callout))">
                                    <xsl:value-of select="normalize-space($synnote/@callout)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getVarValueWithLang">
                                        <xsl:with-param name="prmVarName" select="'Sd_Note_Prefix'"/>
                                    </xsl:call-template>
                                    <xsl:number select="."
                                                level="any" 
                                                count="*[contains(@class, ' pr-d/synnote ')][not(@callout)]"
                                                from="*[contains(@class,' pr-d/syntaxdiagram')]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsSynNoteBody'"/>
                            </xsl:call-template>
                            <xsl:call-template name="ahf:getUnivAtts"/>
                            <xsl:if test="empty($synnote/@id)">
                                <xsl:attribute name="id" select="ahf:generateId($synnote,$prmTopicRef)"/>
                            </xsl:if>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty($synnote)"/>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:for-each>
        </fo:list-block>
    </xsl:template>
    
    <!-- syntaxdiagram/title is implementaed as fig/title in dita2fo_bodyelements.xsl -->
    
    <!-- 
     function:	groupseq/groupcomp/groupchoice template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/groupseq ')]
                      |  *[contains(@class,' pr-d/groupcomp ')]
                      |  *[contains(@class,' pr-d/groupchoice ')]"
        mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:choose>
            <xsl:when test="parent::*[contains(@class, ' pr-d/syntaxdiagram ')]
                         or parent::*[contains(@class, ' pr-d/fragment ')]">
                <xsl:sequence select="'atsGroup'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/groupseq ')]
                      |  *[contains(@class,' pr-d/groupcomp ')]
                      |  *[contains(@class,' pr-d/groupchoice ')]"
                  priority="2">
        <xsl:choose>
            <xsl:when test="parent::*[contains(@class, ' pr-d/syntaxdiagram ')]
                         or parent::*[contains(@class, ' pr-d/fragment ')]">
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:call-template name="processGroup"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:wrapper>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:call-template name="processGroup"/>
                </fo:wrapper>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- current context is groupseq, groupcomp or groupchoice -->
    <xsl:template name="processGroup">
        <xsl:variable name="isGroupChoice" as="xs:boolean" select="contains(@class,' pr-d/groupchoice ')"/>
        <xsl:variable name="isOptional"    as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="hasRepSep"     as="xs:boolean" select="exists(child::*[contains(@class,' pr-d/repsep ')])"/>
        <xsl:variable name="isRequiredRepsep" 
                      select="if ($hasRepSep) then string(child::*[contains(@class,' pr-d/repsep ')]/@importance) eq 'required' else false()"/>
        <xsl:variable name="needOr"        select="ahf:sdNeedOr(.)"/>
        
        <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
        
        <xsl:if test="$needOr">
            <!-- | -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <!-- [ -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isGroupChoice">
            <!-- { -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Choice_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="child::*[not(contains(@class,' pr-d/repsep '))][not(contains(@class,' topic/title '))]"/>
        <xsl:if test="$isGroupChoice">
            <!-- } -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Choice_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$hasRepSep">
            <!-- ( -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Repeat_Prefix'"/>
            </xsl:call-template>
            <!-- , (etc) -->
            <xsl:apply-templates select="*[contains(@class,' pr-d/repsep ')]"/>
            <xsl:if test="$isGroupChoice">
                <!-- { -->
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Sd_Choice_Prefix'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="child::*[not(contains(@class,' pr-d/repsep '))][not(contains(@class,' topic/title '))]">
                <xsl:with-param name="prmNeedId" tunnel="yes" select="false()"/>
            </xsl:apply-templates>
            <xsl:if test="$isGroupChoice">
                <!-- } -->
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'Sd_Choice_Suffix'"/>
                </xsl:call-template>
            </xsl:if>
            <!-- ) -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Repeat_Suffix'"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$isRequiredRepsep">
                    <!-- + -->
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Sd_Required_Symbol'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- * -->
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Sd_Optional_Symbol'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$isOptional">
            <!-- ] -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="ahf:sdNeedOr" as="xs:boolean">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:sequence select="$prmElement/parent::*[contains(@class,' pr-d/groupchoice ')] 
                  and  (count($prmElement/preceding-sibling::*[not(contains(@class, ' pr-d/repsep '))]
                                                                [not(contains(@class, ' topic/title '))]) gt 0)"/>
    </xsl:function>
    
    
    <!-- 
     function:	fragment template
     param:	    
     return:	fo:wrapper
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/fragment ')]" priority="2">
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:wrapper>
    </xsl:template>
    
    
    <!-- fragment/title is implemented as figgroup/title in dita2fo_bodyelements.xsl -->
    
    <!-- 
     function:	fragref template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/fragref ')]" priority="2">
        <xsl:variable name="isOptional" as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="orgTitle" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:variable name="hasTitle" as="xs:boolean" select="exists($orgTitle)"/>
        <xsl:variable name="fragrefTitle" as="node()*">
            <xsl:choose>
                <xsl:when test="$hasTitle">
                    <xsl:copy-of select="$orgTitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="fragmentId" select="substring-after(@href,'/')"/>
                    <xsl:variable name="fragmentElement" select="if (string($fragmentId)) then key('elementById',$fragmentId,ancestor::*[contains(@class, ' pr-d/syntaxdiagram ')])[1] else ()" as="element()?"/>
                    <xsl:variable name="fragmentTitle" as="node()*">
                        <xsl:apply-templates select="$fragmentElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                    </xsl:variable>
                    <xsl:copy-of select="$fragmentTitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="needOr" select="ahf:sdNeedOr(.)"/>
        
        <xsl:if test="$needOr">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Fragment_Ref_Prefix'"/>
            </xsl:call-template>
            <xsl:copy-of select="$fragrefTitle"/>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Fragment_Ref_Suffix'"/>
            </xsl:call-template>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	synblk template
     param:	    
     return:	fo:wrapper
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/synblk ')]" priority="2">
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:wrapper>
    </xsl:template>
    
    <!-- 
     function:	synnote template
     param:	    prmTopicRef
     return:	fo:basic-link
     note:		none
     -->
    <xsl:template match="*[contains(@class,' pr-d/synnote ')]" priority="2">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes"  as="element()?"/>
    
        <xsl:variable name="syntaxDiagramElement" select="ancestor::*[contains(@class,' pr-d/syntaxdiagram ')][1]"/>
        <xsl:choose>
            <xsl:when test="@id">
                <!-- referenced by synnoteref -->
            </xsl:when>
            <xsl:otherwise>
                <!-- stand alone synnote -->
                <xsl:variable name="id" select="ahf:generateId(.,$prmTopicRef)"/>
                <fo:basic-link internal-destination="{$id}">
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsSynNote'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:choose>
                        <xsl:when test="string(normalize-space(@callout))">
                            <xsl:value-of select="normalize-space(@callout)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'Sd_Note_Prefix'"/>
                            </xsl:call-template>
                            <xsl:number select="."
                                        level="any" 
                                        count="*[contains(@class, ' pr-d/synnote ')][not(@callout)]"
                                        from="*[contains(@class,' pr-d/syntaxdiagram')]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	synnoteref template
     param:	    prmTopicRef
     return:	fo:basic-link
     note:		referenced synnote must exist in the same sytaxdiagram.
     -->
    <xsl:template match="*[contains(@class,' pr-d/synnoteref ')]" priority="2">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes"  as="element()?"/>
        
        <xsl:variable name="href" as="xs:string" select="@href"/>
        <xsl:variable name="synNoteId" as="xs:string" select="substring-after($href,'/')"/>
        
        <xsl:variable name="syntaxDiagramElement" as="element()" select="ancestor::*[contains(@class, ' pr-d/syntaxdiagram ')][1]"/>
        <xsl:variable name="synNoteElement" as="element()?" select="if (string($synNoteId)) then key('elementById',$synNoteId,$syntaxDiagramElement)[1] else ()"/>
        
        <xsl:choose>
            <xsl:when test="empty($synNoteElement)">
                <!-- DITA-OT already outputs DOTX032E error in topicpull -->
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes">
                        <xsl:value-of select="ahf:replace($stMes060,('%file','%trace','%href'),(string(@xtrf),string(@xtrc),string(@ohref)))"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:basic-link>
                    <xsl:attribute name="internal-destination">
                        <xsl:variable name="synNoteElemIdAtr" select="ahf:getIdAtts($synNoteElement,$prmTopicRef,true())" as="attribute()*"/>
                        <xsl:value-of select="$synNoteElemIdAtr[1]"/>
                    </xsl:attribute>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsSynNote'"/>
                    </xsl:call-template>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:choose>
                        <xsl:when test="string(normalize-space($synNoteElement/@callout))">
                            <xsl:value-of select="normalize-space($synNoteElement/@callout)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'Sd_Note_Prefix'"/>
                            </xsl:call-template>
                            <xsl:number select="$synNoteElement"
                                        level="any" 
                                        count="*[contains(@class, ' pr-d/synnote ')][not(@callout)]"
                                        from="*[contains(@class,' pr-d/syntaxdiagram')]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	kwd template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/kwd ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="if (string(@importance) eq 'default') then 'atsKwdDefault' else 'atsKwd'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/kwd ')]" priority="2">
        <xsl:variable name="isOptional"  as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="needOr"      as="xs:boolean" select="ahf:sdNeedOr(.)"/>
    
        <xsl:if test="$needOr">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	var template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/var ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="if (string(@importance) eq 'default') then 'atsVarDefault' else 'atsVar'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/var ')]" priority="2">
        <xsl:variable name="isOptional"  as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="needOr"      as="xs:boolean" select="ahf:sdNeedOr(.)"/>
    
        <xsl:if test="$needOr">
            <!-- | -->
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	oper template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/oper ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="if (string(@importance) eq 'default') then 'atsOperDefault' else 'atsOper'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' pr-d/oper ')]" priority="2">
        <xsl:variable name="isOptional"  as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="needOr"      as="xs:boolean" select="ahf:sdNeedOr(.)"/>
    
        <xsl:if test="$needOr">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	delim template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/delim ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="if (string(@importance) eq 'default') then 'atsDelimDefault' else 'atsDelim'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/delim ')]" priority="2">
        <xsl:variable name="isOptional"  as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="needOr"      as="xs:boolean" select="ahf:sdNeedOr(.)"/>
    
        <xsl:if test="$needOr">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:copy-of select="ahf:getLocalizationAtts(.)"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	sep template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' pr-d/sep ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="if (string(@importance) eq 'default') then 'atsSepDefault' else 'atsSep'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/sep ')]" priority="2">
        <xsl:variable name="isOptional"  as="xs:boolean" select="string(@importance) eq 'optional'"/>
        <xsl:variable name="needOr"      as="xs:boolean" select="ahf:sdNeedOr(.)"/>
        
        <xsl:if test="$needOr">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Or'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Prefix'"/>
            </xsl:call-template>
        </xsl:if>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
        <xsl:if test="$isOptional">
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Sd_Optional_Suffix'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	repsep template
     param:	    
     return:	fo:inline
     note:		@importance is processed in processGroup template.
     -->
    <xsl:template match="*[contains(@class,' pr-d/repsep ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>