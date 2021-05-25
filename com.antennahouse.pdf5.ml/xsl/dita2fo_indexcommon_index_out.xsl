<?xml version="1.0" encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Index common template
    Copyright © 2009-2021 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:fo="http://www.w3.org/1999/XSL/Format" 
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
     xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
     xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
     exclude-result-prefixes="xs ahf axf psmi"
    >
    <!-- *************************************** 
            Keys
         ***************************************-->
    <!-- index-see, index-see-also key -->
    <xsl:key name="indextermBySee" match="$indextermSorted/index-data" use="@seekey"/>
    <xsl:key name="indextermBySeeAlso" match="$indextermSorted/index-data" use="@seealsokey"/>
    <xsl:key name="indextermByIndexKeyForSee" match="$indextermSorted/index-data" use="@indexkeyForSee"/>
    
    <!-- *************************************** 
            Index related
         ***************************************-->
    <xsl:variable name="cIndexSymbolLabel" select="ahf:getVarValue('Index_Symbol_Label')" as="xs:string"/>
    <xsl:variable name="cSeePrefixLevel1"  select="ahf:getVarValue('See_Prefix_Level1')" as="xs:string"/>
    <xsl:variable name="cSeeSuffixLevel1"  select="ahf:getVarValue('See_Suffix_Level1')" as="xs:string"/>
    <xsl:variable name="cSeePrefixLevel2"  select="ahf:getVarValue('See_Prefix_Level2')" as="xs:string"/>
    <xsl:variable name="cSeeSuffixLevel2"  select="ahf:getVarValue('See_Suffix_Level2')" as="xs:string"/>
    
    <!-- Index See Also prefix and suffix -->
    <xsl:variable name="cSeeAlsoPrefix" select="ahf:getVarValue('See_Also_Prefix')" as="xs:string"/>
    <xsl:variable name="cSeeAlsoSuffix" select="ahf:getVarValue('See_Also_Suffix')" as="xs:string"/>
    
    <!-- Index page citation -->
    <xsl:variable name="cIndexPageCitationListSeparator" select="ahf:getVarValue('Index_Page_Citation_List_Separator')" as="xs:string"/>
    <xsl:variable name="cIndexPageCitationRangeSeparator" select="ahf:getVarValue('Index_Page_Citation_Range_Separator')" as="xs:string"/>

    <!-- indexkey for @significance="preferred" (DocBook Only) -->
    <xsl:variable name="KEY_PREFERRED" select="'__KEY_PREFERRED'" as="xs:string"/>
    
    <!-- Sort key max length (When stylesheet does not use I18n Index Library) -->
    <xsl:variable name="cIndexSortKeyMaxLen" select="128" as="xs:integer"/>
    
    <!-- index-key separator -->
    <!--xsl:variable name="indexKeySep" select="':'"/-->
    
    <!-- index id prefix -->
    <xsl:variable name="cIndexKeyPrefix" select="'__indexkey'"/>

    <!-- group title returned from Java index sorting module -->
    <xsl:variable name="cGroupTitleOthers" select="'#NUMERIC'" as="xs:string"/>

    <!-- significance index -->
    <xsl:variable name="cSignificanceNormal" as="xs:integer" select="1"/>
    <xsl:variable name="cSignificancePrefeered" as="xs:integer" select="2"/>
    
    <!-- 
         Function: Make index page sequence
         Param:    none.
         Return:   fo:page-sequence 
         Note:     Current is booklists/indexlist
      -->
    <xsl:template name="genIndex">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        
        <!-- Inform new module -->
        <xsl:message select="'[INFO][genIndex] Running on refined XSLT 3.0 index processing module.'"/>
        
    	<!-- debug -->
    	<xsl:if test="$indextermOriginCount != $indextermSortedCount">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes600,('%before','%after'),(string($indextermOriginCount),string($indextermSortedCount)))"/>
            </xsl:call-template>
    	</xsl:if>
    
        <xsl:if test="$pDebugIndex">
            <xsl:call-template name="indexDump"/>
        </xsl:if>
    	
        <xsl:if test="$pOutputIndex and ($indextermSortedCount &gt; 0)">
    	    <psmi:page-sequence>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqIndex')"/>
                <fo:static-content flow-name="rgnIndexBeforeLeft">
		            <xsl:call-template name="indexBeforeLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBeforeRight">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterLeft">
		            <xsl:call-template name="indexAfterLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterRight">
                    <xsl:call-template name="indexAfterRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndRight">
                    <xsl:call-template name="indexEndRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndLeft">
                    <xsl:call-template name="indexEndLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBlankBody">
                    <xsl:call-template name="makeBlankBlock"/>
                </fo:static-content>
        		
        		<!-- INDEX main flow -->
        		<fo:flow flow-name="xsl-region-body">
                    <!-- Make "INDEX" title  -->
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexHeader')"/>
                        <xsl:attribute name="id" select="$id"/>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline><xsl:copy-of select="$cIndexTitle"/></fo:inline>
                        </fo:marker>
                        <xsl:value-of select="$cIndexTitle"/>
                    </fo:block>
                    <!-- Make index content main -->
                    <xsl:call-template name="makeIndexContentControl"/>
        		</fo:flow>
        	</psmi:page-sequence>
        </xsl:if>
    </xsl:template>
    
    <!-- 
         Function: Make index page sequence for simple map
         Param:    none.
         Return:   fo:page-sequence 
         Note:     
      -->
    <xsl:template name="genMapIndex">
        
        <!-- debug -->
        <xsl:if test="$indextermOriginCount != $indextermSortedCount">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes600,('%before','%after'),(string($indextermOriginCount),string($indextermSortedCount)))"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$indextermSortedCount &gt; 0">
            <fo:page-sequence>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqIndex')"/>
                <fo:static-content flow-name="rgnIndexBeforeLeft">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBeforeRight">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterLeft">
                    <xsl:call-template name="indexAfterLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterRight">
                    <xsl:call-template name="indexAfterRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndRight">
                    <xsl:call-template name="indexEndRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndLeft">
                    <xsl:call-template name="indexEndLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBlankBody">
                    <xsl:call-template name="makeBlankBlock"/>
                </fo:static-content>
                
                <!-- INDEX main flow -->
                <fo:flow flow-name="xsl-region-body">
                    <!-- Make "INDEX" title  -->
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexHeader')"/>
                        <xsl:attribute name="id" select="$cIndexId"/>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline><xsl:copy-of select="$cIndexTitle"/></fo:inline>
                        </fo:marker>
                        <xsl:value-of select="$cIndexTitle"/>
                    </fo:block>
                    <!-- Make index content main -->
                    <xsl:call-template name="makeIndexContentControl"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- 
     function: Making index content index group control 
     param:    None
     return:   
     note:     
    -->
    <xsl:template name="makeIndexContentControl">
        <xsl:for-each-group select="$indextermSorted/index-data" group-adjacent="@group-label">
            <xsl:variable name="indexDataGroup" as="element()+" select="current-group()"/>
            <xsl:variable name="groupLabel" as="xs:string" select="current-grouping-key()"/>
            <!-- set group label -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexGroupTitle')"/>
                <!-- CHANGE: If group-label == "#NUMERIC", replace it symbol label.
                 2009-03-27 t.makita
                 -->
                <xsl:choose>
                    <xsl:when test="$groupLabel eq $cGroupTitleOthers">
                        <!-- This occurs only when using I18n Index library. -->
                        <xsl:value-of select="$cIndexSymbolLabel"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$groupLabel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
            <xsl:call-template name="makeIndexGroupControl">
                <xsl:with-param name="prmIndexDataGroup" as="element()+" select="$indexDataGroup"/>
            </xsl:call-template>            
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- function:  Index group control
         param:     prmIndexDataGroup
         return:    detailed line
    -->
    <xsl:template name="makeIndexGroupControl">
        <xsl:param name="prmIndexDataGroup" required="yes" as="element()+"/>
    
        <xsl:for-each-group select="$prmIndexDataGroup" composite="no" group-adjacent="ahf:getFirstIndexTermGroupKey(.)">
            <xsl:variable name="firstLevelIndexDataGroup" as="element()+" select="current-group()"/>
            <xsl:variable name="firstLevelIndexDataGroupDoc" as="document-node()">
                <xsl:document>
                    <xsl:copy-of select="$firstLevelIndexDataGroup"/>
                </xsl:document>
            </xsl:variable>
            <!--xsl:variable name="maxLevel" as="xs:integer" select="max($indexDataSeq/@level ! xs:integer(.))"/-->
            <xsl:for-each-group select="$firstLevelIndexDataGroup" composite="yes" group-adjacent="ahf:getSecondIndexTermGroupKey(.)">
                <xsl:variable name="secondLevelIndexDataGroup" as="element()+" select="current-group()"/>
                <xsl:variable name="indexData" as="element()" select="$secondLevelIndexDataGroup[1]"/>
                <xsl:variable name="secondLevelIndexDataGroupDoc" as="document-node()">
                    <xsl:document>
                        <xsl:copy-of select="$secondLevelIndexDataGroup"/>
                    </xsl:document>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$indexData/@seekey => empty() and $indexData/@seealsokey => empty()">
                        <xsl:call-template name="outIndextermDetailLine">
                            <xsl:with-param name="prmIndexData" select="$indexData"/>
                            <xsl:with-param name="prmFirstLevelIndexDataGroupDoc"  select="$firstLevelIndexDataGroupDoc"/>
                            <xsl:with-param name="prmSecondLevelIndexDataGroupDoc"  select="$secondLevelIndexDataGroupDoc"/>
                        </xsl:call-template>                        
                    </xsl:when>
                    <xsl:when test="$indexData/@seekey => exists() and $indexData/@seealsokey => empty()">
                        <xsl:call-template name="outSeeDetailLine">
                            <xsl:with-param name="prmIndexData" select="$indexData"/>
                            <xsl:with-param name="prmFirstLevelIndexDataGroupDoc"  select="$firstLevelIndexDataGroupDoc"/>
                            <xsl:with-param name="prmSecondLevelIndexDataGroupDoc"  select="$secondLevelIndexDataGroupDoc"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$indexData/@seekey => empty() and $indexData/@seealsokey => exists()">
                        <xsl:call-template name="outSeeAlsoDetailLine">
                            <xsl:with-param name="prmIndexData" select="$indexData"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:template>
    
    <!--    function: Get first indexterm adjacent grouping key
            param:    prmIndexData
            return:   xs:string
            note:     Group by first level indexterm
     -->
    <xsl:function name="ahf:getFirstIndexTermGroupKey" as="xs:string">
        <xsl:param name="prmIndexdata" as="element()"/>
        <xsl:sequence select="$prmIndexdata/indexterm[1]/@indexkeyForSee => string()"/>
    </xsl:function>
    
    <xsl:function name="ahf:getSecondIndexTermGroupKey" as="xs:string+">
        <xsl:param name="prmIndexdata" as="element()"/>
        <xsl:sequence select="$prmIndexdata/@indexkeyForSee => string()"/>
        <xsl:sequence select="$prmIndexdata/@level => string()"/>
        <xsl:sequence select="if ($prmIndexdata/@seekey => exists()) then $prmIndexdata/@seekey => string() else ' '"/>
        <xsl:sequence select="if ($prmIndexdata/@seealsokey => exists()) then $prmIndexdata/@seealsokey => string() else ' '"/>
    </xsl:function>

    <!--    function: Output indexterm detail line
            param:    See below
            return:   indexterm detil lines
            note:     none
    -->
    <xsl:template name="outIndextermDetailLine">
        <xsl:param name="prmIndexData" required="yes" as="element()"/>
        <xsl:param name="prmFirstLevelIndexDataGroupDoc" required="yes" as="document-node()"/>
        <xsl:param name="prmSecondLevelIndexDataGroupDoc" required="yes" as="document-node()"/>
        
        <xsl:variable name="currentLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer()"/>
        <xsl:variable name="precedingIndexData" as="element()?" select="$prmFirstLevelIndexDataGroupDoc/*[. is $prmIndexData]/preceding-sibling::index-data[1]"/>
        <xsl:variable name="prevLevel" as="xs:integer" select="if ($precedingIndexData => exists()) then $precedingIndexData/@level => xs:integer() else 0"/>

        <xsl:variable name="startLevel" as="xs:integer" select="ahf:getIndextermStartLevel($prmIndexData, $prmFirstLevelIndexDataGroupDoc)"/>
        
        <!-- Significance -->
        <xsl:variable name="significance" as="xs:integer+" select="ahf:getIndextermSignificance($prmSecondLevelIndexDataGroupDoc)"/>
            
        <!-- Requirement for generating @id for current index-data -->
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="ahf:getIdRequirementForIndexterm($prmIndexData)"/>

        <xsl:call-template name="outIndextermDetailLineImpl">
            <xsl:with-param name="prmIndexData" select="$prmIndexData"/>
            <xsl:with-param name="prmStartLevel" select="$startLevel"/>
            <xsl:with-param name="prmSignificance" select="$significance"/>
            <xsl:with-param name="prmShouldGenerateId" select="$shouldGenerateId"/>
        </xsl:call-template>

    </xsl:template>

    <!--    function: Get indexterm start level
            param:    prmIndexData, prmIndexDataGroup
            return:   Start level of indexterm when formatting prmIndexdata
            note:     
    -->
    <xsl:function name="ahf:getIndextermStartLevel" as="xs:integer">
        <xsl:param name="prmIndexData" as="element()"/>
        <xsl:param name="prmIndexDataGroupDoc" as="document-node()"/>

        <xsl:variable name="currentLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer()"/>
        <xsl:variable name="precedingIndexData" as="element()?" select="$prmIndexDataGroupDoc/*[. is $prmIndexData]/preceding-sibling::index-data[1]"/>
        <xsl:variable name="prevLevel" as="xs:integer" select="if ($precedingIndexData => exists()) then $precedingIndexData/@level => xs:integer() else 0"/>
        
        <xsl:variable name="startLevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$currentLevel gt $prevLevel">
                    <!-- Level sequentially increased -->
                    <xsl:sequence select="$prevLevel + 1"/>
                </xsl:when>
                <xsl:when test="$currentLevel eq $prevLevel">
                    <!-- Same level and different key --> 
                    <xsl:sequence select="$prevLevel"/>
                </xsl:when>
                <xsl:when test="$currentLevel lt $prevLevel">
                    <xsl:choose>
                        <xsl:when test="$prevLevel eq 0">
                            <!-- Start of a group -->
                            <xsl:sequence select="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- ???? -->
                            <xsl:variable name="prevLowerLevelIndexData" as="element()?" select="$prmIndexDataGroupDoc/*[. is $prmIndexData]/preceding-sibling::index-data[@level => xs:integer() le $currentLevel][1]"/>
                            <xsl:variable name="prevLowerLevel" as="xs:integer">
                                <xsl:variable name="lowerLevel" as="xs:integer?" select="if ($prevLowerLevelIndexData => exists()) then $prevLowerLevelIndexData/@level => xs:integer() - 1 else ()"/>
                                <xsl:choose>
                                    <xsl:when test="$lowerLevel => empty()">
                                        <xsl:sequence select="2"/>
                                    </xsl:when>
                                    <xsl:when test="$lowerLevel gt 1">
                                        <xsl:sequence select="$lowerLevel"/>
                                    </xsl:when>
                                    <xsl:when test="$lowerLevel le 1">
                                        <xsl:call-template name="warningContinue">
                                            <xsl:with-param name="prmMes" select="ahf:replace('[genIndex/startLevel] Invalid indexterm sequence. key=''%key''',('%key'),($prmIndexData/@indexKeyForSee))"/>
                                        </xsl:call-template>
                                        <xsl:sequence select="2"/>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:sequence select="$lowerLevel"/>
                            </xsl:variable>
                            <xsl:sequence select="$prevLowerLevel"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$startLevel"/>
    </xsl:function>

    <!--    function: Get significance of the indexterm group
            param:    prmIndexDataGroup
            return:   significanceNormal, significancePreferred
            note:     Significance is used in DocBook not in DITA
    -->
    <xsl:function name="ahf:getIndextermSignificance" as="xs:integer+">
        <xsl:param name="prmIndexDataGroupDoc" as="document-node()"/>
        <xsl:variable name="significancePreferred" as="xs:integer" select="$prmIndexDataGroupDoc/*/@significance[. eq 'preferred'] => count()"/>
        <xsl:variable name="significanceNormal" as="xs:integer" select="$prmIndexDataGroupDoc/*/@significance[. eq 'normal'] => count()"/>
        <xsl:sequence select="($significanceNormal, $significancePreferred)"/>
    </xsl:function>

    <!--    function: Get requirement to generate @id for indexterm
            param:    prmIndexDataGroup
            return:   significanceNormal, significancePreferred
            note:     If the key of prmIndexData is referenced from index-see or index-see-also, return true.
    -->
    <xsl:function name="ahf:getIdRequirementForIndexterm" as="xs:boolean">
        <xsl:param name="prmIndexData" as="element()"/>
        
        <xsl:variable name="currentIndexKeyForSee" as="xs:string" select="$prmIndexData/@indexkeyForSee => xs:string()"/>
        <xsl:variable name="isReferenced" as="xs:boolean" select="key('indextermBySee', $currentIndexKeyForSee, $indextermSorted) => exists() or key('indextermBySeeAlso', $currentIndexKeyForSee, $indextermSorted) => exists()"/>
        <xsl:variable name="isFirstOccurence" as="xs:boolean" select="$prmIndexData/preceding-sibling::index-data[@indexkeyForSee  => string() eq $currentIndexKeyForSee] => empty()"/>
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="$pMakeSeeLink and $isReferenced and $isFirstOccurence"/>
        <xsl:sequence select="$shouldGenerateId"/>
    </xsl:function>

    <!--    function: Output indexterm detail line
            param:    prmIndexData, prmStartLevel, prmsignificancePreferred, prmSignificanceNormal
            return:   fo:block
            note:     Common template for indexterm output
    -->
    <xsl:template name="outIndextermDetailLineImpl">
        <xsl:param name="prmIndexData" as="element()" required="yes"/>
        <xsl:param name="prmStartLevel" as="xs:integer" required="yes"/>
        <xsl:param name="prmSignificance" as="xs:integer+" required="yes"/>
        <xsl:param name="prmShouldGenerateId" as="xs:boolean" required="yes"/>
        
        <xsl:variable name="currentLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer()"/>

        <xsl:for-each select="$prmIndexData/indexterm">
            <xsl:variable name="levelPosition" select="position()"/>
            <xsl:if test="$levelPosition ge $prmStartLevel">
                <xsl:variable name="indexterm" as="element()" select="."/>
                <xsl:variable name="indextermFO" as="node()+" select="$indexterm/indextermfo"/>
                <xsl:variable name="indexKeyForSee" as="xs:string" select="$indexterm/@indexkeyForSee => string()"/>
                <xsl:choose>
                    <xsl:when test="$levelPosition le $currentLevel">
                        <!-- This line is only indexterm title 
                             Do not set id for See, SeeAlso reference.
                          -->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($levelPosition)))"/>
                            <fo:inline><xsl:copy-of select="$indextermFO"/></fo:inline>
                        </fo:block>
                    </xsl:when>
                    <xsl:when test="$currentLevel eq $levelPosition">
                        <!-- This line is title and fo:index-citation-list -->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($levelPosition)))"/>
                            <fo:inline>
                                <!-- Generate @id only when it is referenced via index-see or index-see-also
                                     2021-05-22 t.makita
                                  -->
                                <xsl:if test="$prmShouldGenerateId">
                                    <!-- Make @id from @indexKeyForSee, because it has no index-sort-as content.
                                         2019-11-03 t.makita
                                     -->
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="$indexterm/@indexKeyForSee => string() => ahf:indexKeyToIdValue()"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="$indextermFO"/>
                            </fo:inline>
                            <fo:leader>
                                <xsl:copy-of select="ahf:getAttributeSet('atsIndexLeader1')"/>
                            </fo:leader>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsIndex2ndLeaderInline')"/>
                                <fo:leader>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsIndexLeader2')"/>
                                </fo:leader>
                            </fo:inline>
                            <fo:index-page-citation-list>
                                <fo:index-page-citation-list-separator>
                                    <xsl:value-of select="$cIndexPageCitationListSeparator"/>
                                </fo:index-page-citation-list-separator>
                                <fo:index-page-citation-range-separator>
                                    <xsl:value-of select="$cIndexPageCitationRangeSeparator"/>
                                </fo:index-page-citation-range-separator>
                                <xsl:if test="$prmSignificance[$cSignificancePrefeered] gt 0">
                                    <xsl:variable name="preferredIndexKey">
                                        <xsl:value-of select="$prmIndexData/@indexKey"/>
                                        <xsl:value-of select="$indexKeySep"/>
                                        <xsl:value-of select="$KEY_PREFERRED"/>
                                    </xsl:variable>
                                    <fo:index-key-reference ref-index-key="{$preferredIndexKey}"> 
                                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference atsIndexPreferred')"/>
                                    </fo:index-key-reference>
                                </xsl:if>
                                <xsl:if test="$prmSignificance[$cSignificanceNormal] gt 0">
                                    <fo:index-key-reference ref-index-key="{$prmIndexData/@indexKey}">
                                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference')"/>
                                    </fo:index-key-reference>
                                </xsl:if>
                            </fo:index-page-citation-list>
                        </fo:block>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    

    <!--    function: Output index-see detail line
            param:    See below
            return:   fo:block
            note:     index-see is always with indexterm
    -->
    <xsl:template name="outSeeDetailLine">
        <xsl:param name="prmIndexData" as="element()" required="yes"/>
        <xsl:param name="prmFirstLevelIndexDataGroupDoc" required="yes" as="document-node()"/>
        <xsl:param name="prmSecondLevelIndexDataGroupDoc" required="yes" as="document-node()"/>
        
        <xsl:variable name="currentLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer()"/>
        <xsl:variable name="precedingIndexData" as="element()?" select="$prmFirstLevelIndexDataGroupDoc/*[. is $prmIndexData]/preceding-sibling::index-data[1]"/>
        <xsl:variable name="prevLevel" as="xs:integer" select="if ($precedingIndexData => exists()) then $precedingIndexData/@level => xs:integer() else 0"/>
        
        <xsl:variable name="startLevel" as="xs:integer" select="ahf:getIndextermStartLevel($prmIndexData, $prmFirstLevelIndexDataGroupDoc)"/>
        
        <!-- Significance -->
        <xsl:variable name="significance" as="xs:integer+" select="ahf:getIndextermSignificance($prmSecondLevelIndexDataGroupDoc)"/>
        
        <!-- Requirement for generating @id for current index-data -->
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="ahf:getIdRequirementForIndexterm($prmIndexData)"/>
        
        <xsl:call-template name="outIndextermDetailLineImpl">
            <xsl:with-param name="prmIndexData" select="$prmIndexData"/>
            <xsl:with-param name="prmStartLevel" select="$startLevel"/>
            <xsl:with-param name="prmSignificance" select="$significance"/>
            <xsl:with-param name="prmShouldGenerateId" select="$shouldGenerateId"/>
        </xsl:call-template>

        <xsl:variable name="seeKey" as="xs:string" select="$prmIndexData/@seeKey => string()"/>
        <xsl:variable name="seeKeyId" as="xs:string" select="$seeKey => ahf:indexKeyToIdValue()"/>
        <xsl:variable name="seeFO" as="node()*" select="$prmIndexData/indexseefo/node()"/>
        
        <!-- See entry as indented-->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($startLevel + 1)))"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeePrefix')"/>
                <xsl:value-of select="$cSeePrefixLevel2"/>
            </fo:inline>
            <xsl:choose>
                <xsl:when test="$pMakeSeeLink">
                    <fo:basic-link internal-destination="{$seeKeyId}">
                        <xsl:copy-of select="$seeFO"/>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline>
                        <xsl:copy-of select="$seeFO"/>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeeSuffix')"/>
                <xsl:value-of select="$cSeeSuffixLevel2"/>
            </fo:inline>
        </fo:block>
    </xsl:template>

    <!--    function: Output index-see-also detail line
            param:    See below
            return:   fo:block
            note:     index-see-also is independent from relevant indexterm
    -->
    <xsl:template name="outSeeAlsoDetailLine">
        <xsl:param name="prmIndexData" as="element()" required="yes"/>
        
        <!-- Start level -->
        <xsl:variable name="startLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer() + 1"/>
        
        <!-- SeeAlso key -->
        <xsl:variable name="seeAlsoKey" as="xs:string" select="$prmIndexData/@seealsokey => string()"/>
        <xsl:variable name="seeAlsoId"  as="xs:string" select="ahf:indexKeyToIdValue($seeAlsoKey)"/>
        <xsl:variable name="seeAlsoFO"  as="node()+" select="$prmIndexData/indexseealsofo/node()"/>

        <!-- Check see-also destination
             2021-05-23 t.makita
         -->
        <xsl:variable name="seeAlsoTargetIndexterm" as="element()*" select="key('indextermByIndexKeyForSee', $seeAlsoKey, $indextermSorted)"/>
        <xsl:if test="$seeAlsoTargetIndexterm => empty()">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes664,('%see-also-key'),($seeAlsoKey))"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- Output see also block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($startLevel)))"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeeAlsoPrefix')"/>
                <xsl:value-of select="$cSeeAlsoPrefix"/>
            </fo:inline>
            <xsl:choose>
                <xsl:when test="$pMakeSeeLink">
                    <fo:basic-link internal-destination="{$seeAlsoId}">
                        <xsl:copy-of select="$seeAlsoFO"/>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline>
                        <xsl:copy-of select="$seeAlsoFO"/>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeeAlsoSuffix')"/>
                <xsl:value-of select="$cSeeAlsoSuffix"/>
            </fo:inline>
        </fo:block>
    </xsl:template>

    <!--    function: Get id value from index key
            param: prmKey
            return: id string
            note:none
     -->
    <xsl:function name="ahf:indexKeyToIdValue" as="xs:string">
        <xsl:param name="prmKey" as ="xs:string"/>
        <xsl:sequence select="concat($cIndexKeyPrefix,'_',ahf:stringToHexString($prmKey))"/>
    </xsl:function>
    
    <!-- 
	     indexDump template
	     function: Save $indextermOrigin, $indextermSorted to file for debugging.
	     param: none
	     note:
	  -->
    <xsl:template name="indexDump">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="$stMes601"/>
        </xsl:call-template>
        
        <!-- $indextermOrigin -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$indextermOrigin.xml')}">
            <root>
                <xsl:copy-of select="$indextermOrigin"/>
            </root>
        </xsl:result-document>

        <!-- $indextermSorted -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$indextermSorted.xml')}">
            <root>
                <xsl:copy-of select="$indextermSorted"/>
            </root>
        </xsl:result-document>

        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="$stMes602"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
