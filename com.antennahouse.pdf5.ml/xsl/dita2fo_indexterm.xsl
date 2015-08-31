<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Indexterm template
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

    <!-- Class value -->
    <xsl:variable name="CLASS_INDEXTERM"     select="' topic/indexterm '"/>
    <xsl:variable name="CLASS_INDEX_SEE"     select="' indexing-d/index-see '"/>
    <xsl:variable name="CLASS_INDEX_SEEALSO" select="' indexing-d/index-see-also '"/>
    <xsl:variable name="CLASS_INDEX_SORTAS"  select="' indexing-d/index-sort-as '"/>
    
    <xsl:variable name="CLASS_TOPICMETA"     select="' map/topicmeta '"/>
    <xsl:variable name="CLASS_KEYWORDS"      select="' topic/keywords '"/>
    
    
    <!-- Attribute check template return string -->
    <xsl:variable name="INDEX_CHECK_IGNORE_ELEMENT"   select="'INDEX_CHECK_IGNORE_ELEMENT'"/>
    <xsl:variable name="INDEX_CHECK_IGNORE_ATTRIBUTE" select="'INDEX_CHECK_IGNORE_ATTRIBUTE'"/>
    <xsl:variable name="INDEX_CHECK_OK"               select="'INDEX_CHECK_OK'"/>
    
    <!-- Key definition -->
    <xsl:key name="KEY_INDEX_START" match="*[contains(@class, ' topic/indexterm ')][not(ancestor::*[contains(@class,' topic/navtitle ')])]" use="@start"/>
    <xsl:key name="KEY_INDEX_END"   match="*[contains(@class, ' topic/indexterm ')][not(ancestor::*[contains(@class,' topic/navtitle ')])]" use="@end"  />
    
    
    <!-- 
     function:	Indexterm main template for generating @index-key, 
                fo:index-range-begin and fo:index-range-end.
     param:		- prmIndextermKey
                  Inherited string index key value for making @index-key attribute.
                - prmIndextermStart
                  Inherited string(indexterm/@start) value.
                - prmIndextermStartId
                  Inherited id of indexterm[@start].
                - prmMakeKeyAndStart
                  Tunnel paramter. This paramter become true() when processing following:
                   topicref/topicmeta/keywords/indexterm
                   topic/prolog/metadata/keywords/indexterm
                - prmMakeEnd
                  Tunnel parameter. This paramter exists to process indexterm[@end] for making fo:index-range-end.
                  Currently this parameter become true() when processing following:
                   topicref/topicmeta/keywords/indexterm
                   topic/prolog/metadata/keywords/indexterm
                - prmMakeComplementEnd
                  Tunnel parameter. This parameter exists to process indexterm[@start] that has no corresponding 
                  indexterm[@end]. Currently this parameter become true when processing following:
                   topicref/topicmeta/keywords/indexterm
                   topic/prolog/metadata/keywords/indexterm
                - prmRangeElem
                  Tunnel parameter. This paramter specifies tha range to search indexterm[@end].
     return:	fo:wrapper, fo:index-range-begin, fo:index-range-end
     note:		Entry point has moved to dita2fo_indexcommon.xsl.
                This template is called from dita2fo_indexcommon.xsl.
     -->
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]" mode="MODE_PROCESS_INDEXTERM_MAIN">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmIndextermKey" required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermStart" required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermStartId" required="yes" as="xs:string"/>
        <xsl:param name="prmMakeKeyAndStart" tunnel="yes" required="no" select="false()" as="xs:boolean"/>
        <xsl:param name="prmMakeEnd" tunnel="yes" required="no" select="false()" as="xs:boolean"/>
        <xsl:param name="prmMakeComplementEnd" tunnel="yes" required="no" select="false()" as="xs:boolean"/>
        <xsl:param name="prmRangeElem" tunnel="yes" required="no" select="()" as="element()?"/>
        
        <!--xsl:message>CALLED match="*[contains(@class, ' topic/indexterm ')]" mode="MODE_PROCESS_INDEXTERM_MAIN"</xsl:message>
        <xsl:message select="'$prmTopicRef=',if (exists($prmTopicRef)) then 'Not null' else 'Null'"></xsl:message>
        <xsl:message select="'$prmNeedId=',if ($prmNeedId) then 'True' else 'False'"></xsl:message>
        <xsl:message select="'$prmIndextermKey=',$prmIndextermKey"></xsl:message>
        <xsl:message select="'$prmIndextermStart=',$prmIndextermStart"></xsl:message>
        <xsl:message select="'$prmIndextermStartId=',$prmIndextermStartId"></xsl:message>
        <xsl:message select="'$prmMakeAndStart=',string($prmMakeKeyAndStart)"></xsl:message>
        <xsl:message select="'$prmMakeEnd=',string($prmMakeEnd)"></xsl:message>
        <xsl:message select="'$prmMakeComplementEnd=',string($prmMakeComplementEnd)"></xsl:message>
        <xsl:message select="'$prmRangeElem=',if (exists($prmRangeElem)) then 'Not null' else 'Null'"></xsl:message>
        <xsl:message select="'$indexterm=',string(.)"></xsl:message-->
        
        <!-- Indexterm in normal context processing.
             No special tunnel parameter is true.
             This is applied to the following case:
             - Indexterm in topic/title
             - Indexterm in topic/shortdesc,abstract
             - Indexterm in topic/body
         -->
        <xsl:variable name="prmNormalProcessing" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="not($prmMakeKeyAndStart) and not($prmMakeEnd) and not($prmMakeComplementEnd)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
        <!-- Text of this indexterm 
             TEXT_ONLY template is coded in dita2fo_indexcommon.xsl
        -->
        <xsl:variable name="indextermText" as="xs:string">
            <xsl:variable name="tempIndextermText" as="xs:string*">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndextermText" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndextermText,''))"/>
        </xsl:variable>
    
        <!-- Key of this indexterm
             Changed to generate same key with index page.
             2014-09-27 t.makita
         -->
        <xsl:variable name="indextermKey" as="xs:string">
            <xsl:call-template name="getIndextermKey">
                <xsl:with-param name="prmIndexterm" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Current indexterm key -->
        <xsl:variable name="currentIndexKey" as="xs:string">
            <xsl:choose>
                <xsl:when test="not(string($prmIndextermKey))">
                    <xsl:value-of select="$indextermKey"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($prmIndextermKey,$indexKeySep,$indextermKey)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Logical check -->
        <xsl:variable name="indextermStructureCheck" as="xs:string">
            <xsl:call-template name="indextermStructureCheck">
                <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="indextermTextCheck" as="xs:string">
            <xsl:call-template name="indextermTextCheck">
                <xsl:with-param name="prmIndextermText" select="$indextermText"/>
                <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="startAttrCheck" as="xs:string">
            <xsl:call-template name="indexStartAttrCheck">
                <xsl:with-param name="prmIndextermStart" select="$prmIndextermStart"/>
                <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
                <xsl:with-param name="prmDoCheck" select="boolean($prmMakeKeyAndStart or $prmNormalProcessing or $prmMakeComplementEnd)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="endAttrCheck" as="xs:string">
            <xsl:call-template name="indexEndAttrCheck">
                <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
                <xsl:with-param name="prmDoCheck" select="boolean($prmMakeEnd or $prmNormalProcessing)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bothAttrCheck" as="xs:string">
            <xsl:call-template name="indexBothAttrCheck">
                <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!--xsl:if test="@end">
        	<xsl:message select="'@end=',string(@end),' $endAttrCheck=', $endAttrCheck"/>
        </xsl:if-->
        <!--xsl:if test="@start">
        	<xsl:message select="'$prmMakeComplementEnd=',string($prmMakeComplementEnd),'@start=',string(@start),' $startAttrCheck=', $startAttrCheck"/>
        </xsl:if-->
        
        
        
        <xsl:choose>
            <xsl:when test="($indextermStructureCheck=$INDEX_CHECK_IGNORE_ELEMENT) 
                         or ($indextermTextCheck=$INDEX_CHECK_IGNORE_ELEMENT) 
                         or ($startAttrCheck=$INDEX_CHECK_IGNORE_ELEMENT) 
                         or ($endAttrCheck=$INDEX_CHECK_IGNORE_ELEMENT) 
                         or ($bothAttrCheck=$INDEX_CHECK_IGNORE_ELEMENT) ">
                <!-- Error detected at indexterm, text(), @start or @end -->
            </xsl:when>
            <xsl:when test="($endAttrCheck=$INDEX_CHECK_OK) and ($prmMakeEnd or $prmNormalProcessing)">
                <!-- @end is specified. Generate fo:index-range-end
                     The second parameter $prmTopicRef is always empty sequence.
                     This is because if topic that contains indexterm/@start is referenced from map more than once,
                     it is assumed that it is contained in the first referenced topic.
                     2014-09-14 t.makita
                  -->
                <xsl:variable name="refId" select="ahf:generateId(key('KEY_INDEX_START',@end)[1],())"/>
                <fo:index-range-end ref-id="{$refId}"/>
                <!--xsl:message>End generated by $prmMakeEnd refid=<xsl:value-of select="$refId"/> @end=<xsl:value-of select="@end"/></xsl:message-->
            </xsl:when>
            <xsl:when test="$prmMakeComplementEnd and (($startAttrCheck=$INDEX_CHECK_OK)
                         or (string($prmIndextermStartId)))">
                <!-- @start is specified or inherited. Check corresponding @end in search range. -->
                <xsl:variable name="start" select="if (string($prmIndextermStart)) then $prmIndextermStart else string(@start)" as="xs:string"/>
                <xsl:variable name="hasEnd" 
                              select="ahf:findIndextermEnd($start,$prmRangeElem)" as="xs:boolean"/>
                          <!--  select="key('KEY_INDEX_END',$prmIndextermStart, $prmRangeElem)" as="element()*"/-->
                <xsl:if test="not($hasEnd)">
                    <!-- Complement fo:index-range-end -->
                    <fo:index-range-end>
                        <xsl:attribute name="ref-id">
                            <xsl:choose>
                                <xsl:when test="string($prmIndextermStartId)">
                                    <xsl:value-of select="$prmIndextermStartId"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </fo:index-range-end>
                    <!--xsl:message>End generated by $prmMakeComplementEnd @start=<xsl:value-of select="$prmIndextermStart"/> <xsl:value-of select="@start"/> Range class="<xsl:value-of select="$prmRangeElem/@class"/>"</xsl:message-->
                </xsl:if>
            </xsl:when>
            <xsl:when test="child::*[contains(@class, $CLASS_INDEXTERM)]">
                <!-- Navigate to next indexterm -->
                <xsl:apply-templates select="child::*[contains(@class, $CLASS_INDEXTERM)]" mode="MODE_PROCESS_INDEXTERM_MAIN">
                    <xsl:with-param name="prmIndextermKey" select="$currentIndexKey"/>
                    <xsl:with-param name="prmIndextermStart">
                        <xsl:choose>
                            <xsl:when test="$startAttrCheck=$INDEX_CHECK_OK">
                                <xsl:value-of select="@start"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$prmIndextermStart"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="prmIndextermStartId">
                        <xsl:choose>
                            <xsl:when test="$startAttrCheck=$INDEX_CHECK_OK">
                                <!-- The $prmTopicRef parameter is always empty because topic that has ranged indexterm must not be referenced 
                                     more than once.
                                     2014-09-14 t.makita
                                 -->
                                <xsl:value-of select="ahf:generateId(.,())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$prmIndextermStartId"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="prmMakeKeyAndStart" tunnel="yes" select="$prmMakeKeyAndStart"/>
                    <xsl:with-param name="prmMakeEnd" tunnel="yes" select="$prmMakeEnd"/>
                    <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="$prmMakeComplementEnd"/>
                    <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmRangeElem"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="(child::*[contains(@class,$CLASS_INDEX_SEE)])
                     and not(child::*[contains(@class,$CLASS_INDEX_SEEALSO)])">
                <!-- If index-see is child of indexterm,
                     there is no need to generate formatting object or attributes. -->
            </xsl:when>
            <xsl:when test="$prmMakeEnd or $prmMakeComplementEnd">
                <!-- exit -->
            </xsl:when>
            <xsl:when test="($prmMakeKeyAndStart or $prmNormalProcessing) and (($startAttrCheck=$INDEX_CHECK_OK) or (string($prmIndextermStartId)))">
                <!-- @start is specified or inherited. Generate fo:index-range-start -->
                <fo:index-range-begin>
                    <xsl:attribute name="id">
                        <xsl:choose>
                            <xsl:when test="string($prmIndextermStartId)">
                                <xsl:value-of select="$prmIndextermStartId"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>        
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="index-key">
                        <xsl:value-of select="$currentIndexKey"/>
                    </xsl:attribute>
                </fo:index-range-begin>
            </xsl:when>
            <xsl:when test="($prmMakeKeyAndStart or $prmNormalProcessing) and string($currentIndexKey)">
                <!-- Generate fo:wrapper with index-key attribute -->
                <fo:wrapper index-key="{$currentIndexKey}">
                    <!--xsl:attribute name="index-class">
                        Index-class is needed if author use range indexterm that
                        extend part to part or chapter to chapter.
                        Generally there isn't a such case.
                    </xsl:attribute-->
                </fo:wrapper>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Indexterm structure check
     param:	    $prmCurrentIndexKey
     return:	$INDEX_CHECK_IGNORE_ELEMENT, $INDEX_CHECK_OK
     note:		Current is indexterm
     -->
    <xsl:template name="indextermStructureCheck">
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        
        <xsl:if test="(preceding-sibling::*[contains(@class, $CLASS_INDEX_SEE)]) 
                   or (following-sibling::*[contains(@class, $CLASS_INDEX_SEE)])">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes610,('%key','%file'),($prmCurrentIndexKey,@xtrf))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="(preceding-sibling::*[contains(@class, $CLASS_INDEX_SEEALSO)]) 
                   or (following-sibling::*[contains(@class, $CLASS_INDEX_SEEALSO)])">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes611,('%key','%file'),($prmCurrentIndexKey,@xtrf))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="(child::*[contains(@class, $CLASS_INDEX_SEE)]) 
                    and (child::*[contains(@class, $CLASS_INDEX_SEEALSO)])
                    and not(child::*[contains(@class, $CLASS_INDEXTERM)])">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes612,('%key','%file'),($prmCurrentIndexKey,@xtrf))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="$INDEX_CHECK_OK"/>
    </xsl:template>
    
    <!-- 
     function:	Indexterm/text check
     param:	    $prmIndextermText, $prmCurrentIndexKey
     return:	$INDEX_CHECK_IGNORE_ELEMENT, $INDEX_CHECK_OK
     note:		Current is indexterm
     -->
    <xsl:template name="indextermTextCheck">
        <xsl:param name="prmIndextermText" required="yes" as="xs:string"/>
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="not(string($prmIndextermText)) and not(string(@end))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes620,('%key','%file'),($prmCurrentIndexKey,@xtrf))"/>
                </xsl:call-template>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
            </xsl:when>
            <xsl:when test="system-property('use.i18n.index.lib')='yes'">
                <xsl:value-of select="$INDEX_CHECK_OK"/>
            </xsl:when>
            <xsl:when test="string-length($prmIndextermText) &gt; $cIndexSortKeyMaxLen">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes621,('%max','%key','%file'),(string($cIndexSortKeyMaxLen),$prmCurrentIndexKey,@xtrf))"/>
                </xsl:call-template>
                <xsl:value-of select="$INDEX_CHECK_OK"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$INDEX_CHECK_OK"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Indexterm @start check
     param:	    $prmIndextermStart, $prmCurrentIndexKey
     return:	$INDEX_CHECK_IGNORE_ELEMENT, $INDEX_CHECK_OK, $INDEX_CHECK_IGNORE_ATTRIBUTE
     note:		Current is indexterm
     -->
    <xsl:template name="indexStartAttrCheck">
        <xsl:param name="prmIndextermStart" required="yes" as="xs:string"/>
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        <xsl:param name="prmDoCheck" required="yes" as="xs:boolean"/>
        
        <xsl:choose>
            <xsl:when test="string(@start) and $prmDoCheck">
                <xsl:variable name="correspondingEndIndexterm" select="key('KEY_INDEX_END',@start)"/>
                <xsl:choose>
                    <xsl:when test="string($prmIndextermStart)">
                        <!-- @start are specified in a nested indexterm multipully -->
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes630,('%prev','%curr','%key','%file'),($prmIndextermStart,@start,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
                    </xsl:when>
                    <!-- This case is OK!
                         Stylesheet must generate fo:index-range-end in appropriate position.
                     -->
                    <!--xsl:when test="count($correspondingEndIndexterm)=0">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes631,('%start','%key','%file'),(@start,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
                    </xsl:when-->
                    
                    <!-- This case is also OK! 
                         But the result depends on the Formatter specification.
                      -->
                    <!--xsl:when test="count($correspondingEndIndexterm)&gt;1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes632,('%start','%key','%file'),(@start,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
                    </xsl:when-->
                    <xsl:otherwise>
                        <xsl:value-of select="$INDEX_CHECK_OK"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ATTRIBUTE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- 
     function:	Indexterm @end check
     param:		$prmCurrentIndexKey
     return:	$INDEX_CHECK_IGNORE_ELEMENT, $INDEX_CHECK_OK, $INDEX_CHECK_IGNORE_ATTRIBUTE
     note:		Current is indexterm
     -->
    <xsl:template name="indexEndAttrCheck">
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        <xsl:param name="prmDoCheck" required="yes" as="xs:boolean"/>
        
        <xsl:choose>
            <xsl:when test="string(@end) and $prmDoCheck">
                <xsl:variable name="correspondingStartIndexterm" select="key('KEY_INDEX_START',@end)"/>
                <xsl:choose>
                    <xsl:when test="count($correspondingStartIndexterm)=0">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes640,('%end','%key','%file'),(@end,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
                    </xsl:when>
                    <!-- Temporay solution: DITA-OT 1.5.3 copies topic/title to topicref/metadata/navtitle without considering indexterm.
                         2011-12-22 t.makita
                     -->
                    <xsl:when test="count($correspondingStartIndexterm[not(ancestor::*[contains(@class,' topic/navtitle ')])]) gt 1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes641,('%end','%key','%file'),(@end,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <!-- Temporary solution. DITA-OT BUG:2891736 "indexterm in topicref level are copied into topic/prolog" 
                             This bug is fixed in DITA-OT 1.5 M23. Treat it as error.
                             2010/12/15 t.makita
                          -->
                        <!--xsl:value-of select="$INDEX_CHECK_OK"/-->
                        <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
                    </xsl:when>
                    <xsl:when test="ancestor::*[contains(@class, $CLASS_INDEXTERM)]">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes642,('%end','%key','%file'),(@end,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_OK"/>
                    </xsl:when>
                    <xsl:when test="child::*[contains(@class, $CLASS_INDEXTERM)]">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                             select="ahf:replace($stMes643,('%end','%key','%file'),(@end,$prmCurrentIndexKey,@xtrf))"/>
                        </xsl:call-template>
                        <xsl:value-of select="$INDEX_CHECK_OK"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$INDEX_CHECK_OK"/>
                    </xsl:otherwise>
                </xsl:choose>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ATTRIBUTE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Indexterm @start and @end check
     param:		$prmCurrentIndexKey
     return:	$INDEX_CHECK_IGNORE_ELEMENT, $INDEX_CHECK_OK, $INDEX_CHECK_IGNORE_ATTRIBUTE
     note:		Current is indexterm
     -->
    <xsl:template name="indexBothAttrCheck">
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="string(@start) and string(@end)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes650,('%start','%end','%key','%file'),(@start,@end,$prmCurrentIndexKey,@xtrf))"/>
                </xsl:call-template>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
            </xsl:when>
            <xsl:when test="string(@start) and string(descendant::*[contains(@class, CLASS_INSDEXTERM)][string(@end)][1]/@end)">
                <xsl:variable name="end" select="string(descendant::*[contains(@class, CLASS_INSDEXTERM)][string(@end)][1]/@end)" as="xs:string"/>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes651,('%start','%end','%key','%file'),(@start,$end,$prmCurrentIndexKey,@xtrf))"/>
                </xsl:call-template>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
            </xsl:when>
            <xsl:when test="string(@end) and string(descendant::*[contains(@class, CLASS_INSDEXTERM)][string(@start)][1]/@start)">
                <xsl:variable name="start" select="string(descendant::*[contains(@class, CLASS_INSDEXTERM)][string(@start)][1]/@start)" as="xs:string"/>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes652,('%start','%end','%key','%file'),($start,@end,$prmCurrentIndexKey,@xtrf))"/>
                </xsl:call-template>
                <xsl:value-of select="$INDEX_CHECK_IGNORE_ELEMENT"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$INDEX_CHECK_OK"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Find indexterm that have specified @end attribute.
     param:		$prmEnd,$prmRangeElem
     return:	xs:boolean
     note:		$prmRangeElem is $map or topicref
     -->
    <xsl:function name="ahf:findIndextermEnd" as="xs:boolean">
        <xsl:param name="prmEnd" as="xs:string"/>
        <xsl:param name="prmRangeElem" as="element()"/>
        
        <xsl:choose>
            <xsl:when test="contains($prmRangeElem/@class, ' map/topicref ')">
                <xsl:sequence select="ahf:findIndextermEndFromTopicRef($prmEnd, $prmRangeElem, true())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="boolean(key('KEY_INDEX_END',$prmEnd, $prmRangeElem))"/>
                <!--xsl:message>ahf:findIndextermEnd $prmEnd="<xsl:value-of select="$prmEnd"/>" class="<xsl:value-of select="$prmRangeElem/@class"/>" exist="<xsl:value-of select="exists(key('KEY_INDEX_END',$prmEnd, $prmRangeElem))"/>"</xsl:message-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:findIndextermEndFromTopicRef" as="xs:boolean">
        <xsl:param name="prmEnd" as="xs:string"/>
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmStart" as="xs:boolean"/>
    
        <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($id)) then key('topicById', $id, $root)[1] else ()" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <xsl:choose>
                    <xsl:when test="$topicContent/descendant-or-self::*[contains(@class,' topic/topic ')]/child::*[contains(@class, ' topic/prolog ')]/child::*[contains(@class, ' topic/metadata ')]//*[contains(@class, ' topic/indexterm ')][@end=$prmEnd]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="ahf:findIndextermEndFromChildAndSibling($prmEnd,$prmTopicRef,$prmStart)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="ahf:findIndextermEndFromChildAndSibling($prmEnd,$prmTopicRef,$prmStart)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:findIndextermEndFromChildAndSibling" as="xs:boolean">
        <xsl:param name="prmEnd" as="xs:string"/>
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmStart" as="xs:boolean"/>
        
        <xsl:variable name="childValue" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$prmTopicRef/child::*[contains(@class,' map/topiref ')]">
                    <xsl:variable name="childTopicRef" select="$prmTopicRef/child::*[contains(@class,' map/topiref ')][1]"/>
                    <xsl:sequence select="ahf:findIndextermEndFromTopicRef($prmEnd,$childTopicRef,false())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$childValue">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmStart">
                <!-- First topicref. We should not check following-sibling topicref. -->
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$prmTopicRef/following-sibling::*[contains(@class,' map/topicref ')]">
                <xsl:variable name="siblingFollowingTopicRef" select="$prmTopicRef/following-sibling::*[contains(@class,' map/topicref ')][1]"/>
                <xsl:sequence select="ahf:findIndextermEndFromTopicRef($prmEnd,$siblingFollowingTopicRef,false())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>