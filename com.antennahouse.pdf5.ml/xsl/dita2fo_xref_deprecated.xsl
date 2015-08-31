<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: xref element stylesheet
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
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	xref template
     param:	    prmTopicRef, prmNeedId
     return:	fo:basic-link
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' topic/xref ')]">
        <xsl:param name="prmTopicRef" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId"   required="yes"  as="xs:boolean"/>
        
        <xsl:variable name="xref" select="."/>
        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="isLocalHref" select="starts-with($href,'#')"/>
        
        <xsl:choose>
            <xsl:when test="$isLocalHref">
                <xsl:call-template name="processLocalXref">
                    <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
                    <xsl:with-param name="prmXref"     select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processExternalXref">
                    <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
                    <xsl:with-param name="prmXref"     select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Local destination xref
     param:	    prmTopicRef, prmNeedId, prmXref
     return:	fo:basic-link
     note:		none
     -->
    <xsl:template name="processLocalXref">
        <xsl:param name="prmTopicRef" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId"   required="yes"  as="xs:boolean"/>
        <xsl:param name="prmXref"     required="yes"  as="element()"/>
    
        <xsl:variable name="href" select="$prmXref/@href"/>
        <xsl:variable name="destElementId" select="substring-after($href,'/')" as="xs:string"/>
        <xsl:variable name="topicId" select="if (string($destElementId)) then substring-before(substring-after($href,'#'), '/') else (substring-after($href,'#'))" as="xs:string"/>
        <xsl:variable name="topicElement" select="key('topicById', $topicId)[1]" as="element()?"/>
        <xsl:variable name="destElement" select="if (string($destElementId) and exists($topicElement)) then key('elementById',$destElementId,$topicElement)[1] else ()" as="element()?"/>
        <xsl:variable name="topicRefHref" select="if (string($destElementId)) then substring-before($href, '/') else $href" as="xs:string"/>
        <xsl:variable name="topicRef" select="ahf:getTopicRef($topicElement)" as="element()?"/>
        <xsl:variable name="localTopic" select="$prmXref/ancestor::*[contains(@class,' topic/topic ')][last()]" as="element()"/>
        <xsl:variable name="localTopicId" select="string($localTopic/@id)" as="xs:string"/>
        
        <!-- NOTE: Temporary $hasXrefTitle is false.
                   This is because DITA-OT 1.4.3 or 1.5 M19 generates automatically non proper title. 
                   False means that this stylesheet ignores user supplied title for internal xref.
        -->
        <!--xsl:variable name="hasXrefTitle" select="boolean(normalize-space(string($prmXref)))"/-->
        <xsl:variable name="hasXrefTitle" select="false()" as="xs:boolean"/>
    
        <!-- Target is included in middle file but is not included in map. -->
        <xsl:choose>
            <xsl:when test="empty($topicRef)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes072,('%href','%file'),(string(@ohref),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- link to local element in the topic -->
                    <xsl:when test="exists($destElement)">
                        <!-- title -->
                        <xsl:variable name="xrefTitle" as="node()*">
                            <xsl:choose>
                                <xsl:when test="$hasXrefTitle">
                                    <xsl:sequence select="()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getXrefTitle">
                                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                                        <xsl:with-param name="prmDestElement" select="$destElement"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- generate fo:basic-link considering element class
                             Select topicref by topic/@id. 2014-03-25 t.makita
                         -->
                        <xsl:copy-of select="ahf:genXrefToLocalElementFoObject(if ($topicId eq $localTopicId) then $prmTopicRef else $topicRef,$prmNeedId,$prmXref,$destElement,$destElementId,$xrefTitle)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- link to topic -->
                        <xsl:if test="empty($topicElement)">
                            <xsl:call-template name="errorExit">
                                <xsl:with-param name="prmMes"
                                    select="ahf:replace($stMes030,('%h','%file'),($prmXref/@ohref,$prmXref/@xtrf))"/>
                            </xsl:call-template>
                        </xsl:if>
                        <!-- get topic's oid -->
                        <xsl:variable name="topicOidAtr" select="ahf:getIdAtts($topicElement,if ($topicId eq $localTopicId) then $prmTopicRef else $topicRef,true())" as="attribute()*"/>
                        <xsl:variable name="topicOid" select="string($topicOidAtr[1])"/>
                        <!-- title -->
                        <xsl:variable name="xrefTitle" as="node()*">
                            <xsl:choose>
                                <xsl:when test="$hasXrefTitle">
                                    <xsl:sequence select="()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getXrefTitle">
                                        <xsl:with-param name="prmTopicRef" select="if ($topicId eq $localTopicId) then $prmTopicRef else $topicRef"/>
                                        <xsl:with-param name="prmDestElement" select="$topicElement"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- generate fo:basic-link -->
                        <fo:basic-link internal-destination="{$topicOid}">
                            <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                            <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                            <xsl:choose>
                                <xsl:when test="$hasXrefTitle">
                                    <xsl:apply-templates select="$prmXref/child::node()">
                                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                                        <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:inline>
                                        <xsl:copy-of  select="$xrefTitle"/>
                                        <xsl:value-of select="$cXrefPrefix"/>
                                        <fo:page-number-citation ref-id="{$topicOid}"/>
                                        <xsl:value-of select="$cXrefSuffix"/>
                                    </fo:inline>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:basic-link>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    <!-- 
     function:	Get title of xref
     param:		prmTopicRef, prmDestElement
     return:	fo:inline (title string)
     note:		THIS TEMPLATE DOES NOT GENERATE @id ATTRIBUTE
     -->
    <xsl:template name="getXrefTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmDestElement"  required="yes" as="element()"/>
    
        <xsl:choose>
            
            <!-- topic -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/topic ')]">
                <xsl:variable name="titleMode" select="ahf:getTitleMode($prmTopicRef,$prmDestElement)"/>
                <xsl:variable name="topicTitlePrefix">
                    <xsl:choose>
                        <xsl:when test="$titleMode=$cSquareBulletTitleMode">
                            <xsl:value-of select="ahf:getVarValue('Level4_Label_Char')"/>
                        </xsl:when>
                        <xsl:when test="$titleMode=$cRoundBulletTitleMode">
                            <xsl:value-of select="ahf:getVarValue('Level5_Label_Char')"/>
                        </xsl:when>
                        <xsl:when test="$pAddNumberingTitlePrefix">
                            <xsl:call-template name="genTitlePrefix">
                                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
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
                        <xsl:variable name="sectionTitle">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <fo:inline>
                            <xsl:value-of select="ahf:getVarValue('Level5_Label_Char')"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$sectionTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                                            select="ahf:replace($stMes031,('%id','%file'),($prmDestElement/@id,$prmDestElement/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        
            <!-- example -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/example ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="exampleTitle">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <fo:inline>
                            <xsl:value-of select="ahf:getVarValue('Level5_Label_Char')"/>
                            <xsl:text>&#x00A0;</xsl:text>
                            <xsl:copy-of select="$exampleTitle"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                                            select="ahf:replace($stMes032,('%id','%file'),($prmDestElement/@id,$prmDestElement/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
    
            <!-- ol/li -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <xsl:variable name="olFormat" select="ahf:getOlNumberFormat($prmDestElement)" as="xs:string"/>
                <fo:inline>
                    <xsl:number format="{$olFormat}" 
                                value="count($prmDestElement/preceding-sibling::*[contains(@class, ' topic/li ')])+1"/>
                </fo:inline>
            </xsl:when>
            
            <!-- table -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="tableTitle">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <xsl:variable name="tableTitleSuffix"
                                      select="ahf:getTableTitlePrefix($prmTopicRef,$prmDestElement)" 
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
                                            select="ahf:replace($stMes033,('%id','%file'),($prmDestElement/@id,$prmDestElement/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
    
            <!-- fig -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fig ')]">
                <xsl:choose>
                    <xsl:when test="$prmDestElement/*[contains(@class, ' topic/title ')]">
                        <xsl:variable name="figTitle">
                            <xsl:apply-templates select="$prmDestElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                        </xsl:variable>
                        
                        <xsl:variable name="figTitleSuffix"
                                      select="ahf:getFigTitlePrefix($prmTopicRef,$prmDestElement)" 
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
                                            select="ahf:replace($stMes034,('%id','%file'),($prmDestElement/@id,$prmDestElement/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
    
            <!-- fn -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fn ')]">
                <xsl:variable name="fnTitle" select="ahf:getFootnotePrefix($prmDestElement, $prmTopicRef)"/>
                <fo:inline>
                    <xsl:value-of select="$fnTitle"/>
                </fo:inline>
            </xsl:when>
    
            <!-- Other elements that have title -->
            <xsl:when test="$prmDestElement[child::*[contains(@class, ' topic/title ')]]">
                <xsl:variable name="title">
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
                        select="ahf:replace($stMes035,('%id','%elem','%file'),($prmDestElement/@id,name($prmDestElement),$prmDestElement/@xtrf))"/>
                </xsl:call-template>
                <xsl:variable name="title">
                    <xsl:apply-templates select="$prmDestElement" mode="TEXT_ONLY"/>
                </xsl:variable>
                <fo:inline>
                    <xsl:copy-of select="$title"/>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    <!-- 
     function:	Generate FO objects for xref
     param:		prmTopicRef, prmNeedId, prmXref, prmDestElement, prmDestElementId, prmXrefTitle
     return:	FO objects
     note:		none
     -->
    <xsl:function name="ahf:genXrefToLocalElementFoObject" as="element()?">
        <xsl:param name="prmTopicRef"      as="element()?"/>
        <xsl:param name="prmNeedId"        as="xs:boolean"/>
        <xsl:param name="prmXref"          as="element()"/>
        <xsl:param name="prmDestElement"   as="element()"/>
        <xsl:param name="prmDestElementId" as="xs:string"/>
        <xsl:param name="prmXrefTitle"     as="node()*"/>
        
        <xsl:variable name="destIdAtr" select="ahf:getIdAtts($prmDestElement,$prmTopicRef,true())" as="attribute()*"/>
        <xsl:variable name="destId" select="string($destIdAtr[1])" as="xs:string"/>
    
        <xsl:choose>
            <!-- section/example -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/section ') or contains(@class, ' topic/example ')]">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of  select="$prmXrefTitle"/>
                            <xsl:value-of select="$cXrefPrefix"/>
                            <fo:page-number-citation ref-id="{$destId}"/>
                            <xsl:value-of select="$cXrefSuffix"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:when>
            
            <!-- ol/li: Xref link color does not apply for ol/li and does not use fo:pagenumber-citation. -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of select="$prmXrefTitle"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:when>
            
            <!-- table/fig: Same as section -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/table ') or contains(@class, ' topic/fig ')]">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of  select="$prmXrefTitle"/>
                            <xsl:value-of select="$cXrefPrefix"/>
                            <fo:page-number-citation ref-id="{$destId}"/>
                            <xsl:value-of select="$cXrefSuffix"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:when>
    
            <!-- fn: Apply fn style -->
            <xsl:when test="$prmDestElement[contains(@class, ' topic/fn ')]">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of select="ahf:getAttributeSet('atsFnPrefix')"/>
                            <xsl:value-of select="$prmXrefTitle"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:when>
    
            <!-- Other elements that have title: same as section -->
            <xsl:when test="$prmDestElement[child::*[contains(@class, ' topic/title ')]]">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of  select="$prmXrefTitle"/>
                            <xsl:value-of select="$cXrefPrefix"/>
                            <fo:page-number-citation ref-id="{$destId}"/>
                            <xsl:value-of select="$cXrefSuffix"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:when>
            
            <!-- Others -->
            <xsl:otherwise>
                <fo:basic-link>
                    <xsl:attribute name="internal-destination" select="$destId"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:choose>
                        <xsl:when test="exists($prmXrefTitle)">
                            <xsl:copy-of select="$prmXrefTitle"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmXref/child::node()">
                                <xsl:with-param name="prmTopcRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"  select="$prmNeedId"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	External destination xref
     param:		prmTopicRef, prmNeedId, prmXref
     return:	fo:basic-link
     note:		none
     -->
    <xsl:template name="processExternalXref">
        <xsl:param name="prmTopicRef" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId"   required="yes"  as="xs:boolean"/>
        <xsl:param name="prmXref"     required="yes"  as="element()"/>
        
        <xsl:variable name="href" select="$prmXref/@href"/>
        <xsl:variable name="isLinkToPdf" select="matches($href,'(\.PDF#|\.pdf#)')"/>
        <!-- Change PDF inner destination to nameddest -->
        <xsl:variable name="modifiedHref" select="replace($href,'(\.PDF#|\.pdf#)','$1nameddest=')"/>
        <xsl:variable name="url" select="concat('url(',$modifiedHref,')')"/>
        <xsl:variable name="hasXrefTitle" select="boolean(normalize-space(string($prmXref)))"/>
    
        <xsl:choose>
            <xsl:when test="$hasXrefTitle">
                <fo:basic-link external-destination="{$url}">
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:if test="$isLinkToPdf">
                        <xsl:attribute name="axf:action-type" select="'gotor'"/>
                    </xsl:if>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($prmXref)"/>
                    <xsl:apply-templates select="$prmXref/child::node()">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
                    </xsl:apply-templates>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <fo:basic-link external-destination="{$url}">
                    <xsl:copy-of select="ahf:getAttributeSet('atsXref')"/>
                    <xsl:copy-of select="ahf:getUnivAtts($prmXref,$prmTopicRef,$prmNeedId)"/>
                    <xsl:if test="$isLinkToPdf">
                        <xsl:attribute name="axf:action-type" select="'gotor'"/>
                    </xsl:if>
                    <xsl:value-of select="$href"/>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- 
        function:	desc template
        param:	    prmTopicRef,prmNeedId
        return:	    only call descendant template
        note:		This template is obsplute. (It will be never called)
        [Other descs]
        fig/desc:     dita2fo_bodyelements.xsl
        object/desc:  Ignored.
        table/desc:   dita2fo_tableelements.xsl
        link/desc:    Ignored.
        linklist/desc:Ignored.
    -->
    <xsl:template match="*[contains(@class, ' topic/xref ')]/*[contains(@class, ' topic/desc ')]">
        <xsl:param name="prmTopicRef" required="yes"  as="element()?"/>
        <xsl:param name="prmNeedId"   required="yes"  as="xs:boolean"/>
        
        <xsl:apply-templates>
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            <xsl:with-param name="prmNeedId"   select="$prmNeedId"/>
        </xsl:apply-templates>
    </xsl:template>

</xsl:stylesheet>