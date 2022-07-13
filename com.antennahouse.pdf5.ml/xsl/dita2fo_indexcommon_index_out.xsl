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
    <xsl:key name="indexDataBySee"            match="$indextermFinalSortedTree/descendant::index-data" use="@seekey"/>
    <xsl:key name="indexDataBySeeAlso"        match="$indextermFinalSortedTree/descendant::index-data" use="@seealsokey"/>
    <xsl:key name="indexDataByIndexKeyForSee" match="$indextermFinalSortedTree/descendant::index-group[(@level => string() eq '1') or (@isLast => string() eq 'yes')]" use="@indexkeyForSee"/>
    
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
    
    <!-- Sort key max length (When stylesheet does not use I18n Index Library) -->
    <xsl:variable name="cIndexSortKeyMaxLen" select="128" as="xs:integer"/>
    
    <!-- index-key separator: defined in dita2fo_indexcommon_indexterm.xsl -->
    <!--xsl:variable name="indexKeySep" select="'&#x0A;'"/-->
    
    <!-- index id prefix -->
    <xsl:variable name="cIndexKeyPrefix" select="'__indexkey'"/>

    <!-- group title returned from Java index sorting module -->
    <xsl:variable name="cGroupTitleOthers" select="'#NUMERIC'" as="xs:string"/>
    
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
        		    <xsl:call-template name="makeIndexGroupLabel"/>
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
                    <xsl:call-template name="makeIndexGroupLabel"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- 
         function: Making index group label 
         param:    None
         return:   fo:block of index group title line
         note:     
    -->
    <xsl:template name="makeIndexGroupLabel">
        <xsl:for-each-group select="$indextermFinalSortedTree/index-group-label" group-adjacent="@group-label">
            <xsl:variable name="indexGroupLabel" as="element()" select="current-group()"/>
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
            <xsl:for-each select="$indexGroupLabel/index-group">
                <xsl:call-template name="processIndexGroup">
                    <xsl:with-param name="prmIndexGroup" select="."/>
                    <xsl:with-param name="prmLevel" select="1"/>
                </xsl:call-template>            
            </xsl:for-each>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- function:  Index group control
         param:     prmIndexDataGroup
         return:    detailed line
    -->
    <xsl:template name="processIndexGroup">
        <xsl:param name="prmIndexGroup" as="element()"  required="yes" />
        <xsl:param name="prmLevel"      as="xs:integer" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="$prmIndexGroup/index-group => exists() and 
                            $prmIndexGroup/index-data  => exists()">
                <xsl:call-template name="processIndexDataSeq">
                    <xsl:with-param name="prmIndexDataSeq" select="$prmIndexGroup/index-data"/>
                    <xsl:with-param name="prmIndexTermFo"  select="$prmIndexGroup/indextermfo"/>
                    <xsl:with-param name="prmLevel"        select="$prmLevel"/>
                </xsl:call-template>
                <xsl:for-each select="$prmIndexGroup/index-group">
                    <xsl:variable name="indexGroup" as="element()" select="."/>
                    <xsl:call-template name="processIndexGroup">
                        <xsl:with-param name="prmIndexGroup" select="$indexGroup"/>
                        <xsl:with-param name="prmLevel"      select="$prmLevel + 1"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$prmIndexGroup/index-group => exists() and
                            $prmIndexGroup/index-data => empty()">
                <xsl:call-template name="outIndexTermTitleOnlyLine">
                    <xsl:with-param name="prmIndexGroup"  select="$prmIndexGroup"/>
                    <xsl:with-param name="prmIndexTermFo" select="$prmIndexGroup/indextermfo"/>
                    <xsl:with-param name="prmLevel"       select="$prmLevel"/>
                </xsl:call-template>
                <xsl:for-each select="$prmIndexGroup/index-group">
                    <xsl:variable name="indexGroup" as="element()" select="."/>
                    <xsl:call-template name="processIndexGroup">
                        <xsl:with-param name="prmIndexGroup" select="$indexGroup"/>
                        <xsl:with-param name="prmLevel"      select="$prmLevel + 1"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:assert test="$prmIndexGroup/indextermfo => exists()" select="'[processIndexGroup] indexGroup/indextermfo is empty. @group-key=' ||  $prmIndexGroup/@group-key"/>
                <xsl:call-template name="processIndexDataSeq">
                    <xsl:with-param name="prmIndexDataSeq" select="$prmIndexGroup/index-data"/>
                    <xsl:with-param name="prmIndexTermFo"  select="$prmIndexGroup/indextermfo"/>
                    <xsl:with-param name="prmLevel"        select="$prmLevel"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!--    function: Output indexterm title only line
            param:    prmIndextermFo, prmLevel
            return:   fo:block
            note:     Output indexterm title only line 
                      Set id if this group is level1 and referenced from index-see or index-see-also.
     -->
    <xsl:template name="outIndexTermTitleOnlyLine">
        <xsl:param name="prmIndexGroup"  as="element()"  required="yes"/>
        <xsl:param name="prmIndexTermFo" as="element()"  required="yes"/>
        <xsl:param name="prmLevel"       as="xs:integer" required="yes"/>
        
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="ahf:getIdRequirementForIndexDataGroup($prmIndexGroup)"/>
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($prmLevel)))"/>
            <xsl:if test="$shouldGenerateId">
                <xsl:attribute name="id" select="$prmIndexGroup/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
            </xsl:if>
            <fo:inline><xsl:copy-of select="$prmIndexTermFo/node()"/></fo:inline>
        </fo:block>
    </xsl:template>

    <!--    function: Output indexterm line from sequence of index-data examining @see, @seealso
            param:    See below
            return:   Set of indexterm detil lines
            note:     none
     -->
    <xsl:template name="processIndexDataSeq">
        <xsl:param name="prmIndexDataSeq" as="element()+" required="yes"/>
        <xsl:param name="prmIndexTermFo"  as="element()"  required="yes"/>
        <xsl:param name="prmLevel"        as="xs:integer" required="yes"/>
        
        <xsl:variable name="indexDataSeqDoc" as="document-node()">
            <xsl:document>
                <xsl:copy-of select="$prmIndexDataSeq"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:for-each select="$prmIndexDataSeq">
            <xsl:variable name="indexData" as="element()" select="."/>
            <xsl:variable name="see" as="attribute()?" select="$indexData/@see"/>
            <xsl:variable name="seeAlso" as="attribute()?" select="$indexData/@seealso"/>
            <xsl:choose>
                <xsl:when test="$see => exists()">
                    <xsl:call-template name="outSeeDetailLine">
                        <xsl:with-param name="prmIndexData" select="$indexData"/>
                        <xsl:with-param name="prmIndexTermFo" select="$prmIndexTermFo"/>
                        <xsl:with-param name="prmLevel"     select="$prmLevel"/>
                        <xsl:with-param name="prmIndexDataSeqDoc" select="$indexDataSeqDoc"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$seeAlso => exists()">
                    <xsl:call-template name="outSeeAlsoDetailLine">
                        <xsl:with-param name="prmIndexData" select="$indexData"/>
                        <xsl:with-param name="prmLevel"     select="$prmLevel"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="outIndextermDetailLine">
                        <xsl:with-param name="prmIndexData" select="$indexData"/>
                        <xsl:with-param name="prmIndexTermFo" select="$prmIndexTermFo"/>
                        <xsl:with-param name="prmLevel"     select="$prmLevel"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!--    function: Output indexterm detail line
            param:    See below
            return:   indexterm detil lines
            note:     none
     -->
    <xsl:template name="outIndextermDetailLine">
        <xsl:param name="prmIndexData" as="element()" required="yes"/>
        <xsl:param name="prmLevel" as="xs:integer" required="yes"/>
        <xsl:param name="prmIndexTermFo"  as="element()"  required="yes"/>
            
        <!-- Requirement for generating @id for current index-data -->
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="ahf:getIdRequirementForIndexData($prmIndexData)"/>

        <xsl:call-template name="outIndextermDetailLineImpl">
            <xsl:with-param name="prmIndexData" select="$prmIndexData"/>
            <xsl:with-param name="prmLevel" select="$prmLevel"/>
            <xsl:with-param name="prmIndexTermFo" select="$prmIndexTermFo"/>
            <xsl:with-param name="prmShouldGenerateId" select="$shouldGenerateId"/>
        </xsl:call-template>

    </xsl:template>

    <!--    function: Get requirement to generate @id for index-data
            param:    prmIndexData
            return:   xs:boolean
            note:     If the key of prmIndexData is referenced from index-see or index-see-also, return true.
                      Check using index-group:
                      If index-group/@isLast="yes" or index-group/@level="1" then @id should be generated if it is first occurrence.
     -->
    <xsl:function name="ahf:getIdRequirementForIndexData" as="xs:boolean">
        <xsl:param name="prmIndexData" as="element()"/>
        
        <xsl:variable name="indexGroup" as="element()" select="$prmIndexData/parent::index-group"/>
        <xsl:variable name="currentIndexKeyForSee" as="xs:string" select="$prmIndexData/@indexkeyForSee => xs:string()"/>
        <xsl:variable name="isReferenced" as="xs:boolean" select="key('indexDataBySee', $currentIndexKeyForSee, $indextermFinalSortedTree) => exists() or key('indexDataBySeeAlso', $currentIndexKeyForSee, $indextermFinalSortedTree) => exists()"/>
        <xsl:variable name="isFirstOccurence" as="xs:boolean">
            <xsl:variable name="sameKeyIndexGroup" as="element()*" select="key('indexDataByIndexKeyForSee',$currentIndexKeyForSee,$indextermFinalSortedTree)"/>
            <xsl:sequence select="$sameKeyIndexGroup[. &lt;&lt; $indexGroup] => empty()"/>
        </xsl:variable>
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="$pMakeSeeLink and $isReferenced and $isFirstOccurence"/>
        <xsl:sequence select="$shouldGenerateId"/>
    </xsl:function>

    <xsl:function name="ahf:getIdRequirementForIndexDataGroup" as="xs:boolean">
        <xsl:param name="prmIndexGroup" as="element()"/>
        
        <xsl:variable name="currentIndexKeyForSee" as="xs:string" select="$prmIndexGroup/@indexkeyForSee => xs:string()"/>
        <xsl:variable name="isReferenced" as="xs:boolean" select="key('indexDataBySee', $currentIndexKeyForSee, $indextermFinalSortedTree) => exists() or key('indexDataBySeeAlso', $currentIndexKeyForSee, $indextermFinalSortedTree) => exists()"/>
        <xsl:variable name="isFirstOccurence" as="xs:boolean">
            <xsl:variable name="sameKeyIndexGroup" as="element()*" select="key('indexDataByIndexKeyForSee',$currentIndexKeyForSee,$indextermFinalSortedTree)"/>
            <xsl:sequence select="$sameKeyIndexGroup[. &lt;&lt; $prmIndexGroup] => empty()"/>
        </xsl:variable>
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="$pMakeSeeLink and $isReferenced and $isFirstOccurence"/>
        <xsl:sequence select="$shouldGenerateId"/>
    </xsl:function>
    
    <!--    function: Output indexterm detail line
            param:    prmIndexData, prmStartLevel, prmsignificancePreferred, prmSignificanceNormal
            return:   fo:block
            note:     Common template for indexterm output
                      Don't generate fo:index-page-citation-list for index-see
    -->
    <xsl:template name="outIndextermDetailLineImpl">
        <xsl:param name="prmIndexData"        as="element()"  required="yes"/>
        <xsl:param name="prmLevel"            as="xs:integer" required="yes"/>
        <xsl:param name="prmIndexTermFo"      as="element()"  required="yes"/>
        <xsl:param name="prmShouldGenerateId" as="xs:boolean" required="yes"/>
        <xsl:param name="prmIsSeeIndexterm"   as="xs:boolean" required="no" select="false()"/>
        
        <!-- This line is title and fo:index-citation-list for last indexterm -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($prmLevel)))"/>
            <fo:inline>
                <!-- Generate @id only when it is referenced via index-see or index-see-also
                     2021-05-22 t.makita
                  -->
                <xsl:if test="$prmShouldGenerateId">
                    <xsl:attribute name="id" select="$prmIndexData/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
                </xsl:if>
                <xsl:copy-of select="$prmIndexTermFo/*"/>
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
                <xsl:variable name="normalIndexKey" as="xs:string" select="$prmIndexData/@indexkey => string()"/>
                <fo:index-key-reference ref-index-key="{$normalIndexKey}">
                    <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference')"/>
                </fo:index-key-reference>
            </fo:index-page-citation-list>
        </fo:block>

    </xsl:template>

    <!--    function: Output index-see detail line
            param:    See below
            return:   fo:block
            note:     index-see is always with indexterm
    -->
    <xsl:template name="outSeeDetailLine">
        <xsl:param name="prmIndexData"       as="element()"  required="yes"/>
        <xsl:param name="prmLevel"           as="xs:integer" required="yes"/>
        <xsl:param name="prmIndexTermFo"     as="element()"  required="yes"/>
        <xsl:param name="prmIndexDataSeqDoc" as="document-node()" required="yes"/>
        
        <!-- Requirement for generating @id for current index-data -->
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="ahf:getIdRequirementForIndexData($prmIndexData)"/>

        <xsl:variable name="indexTermDetailNotExists" as="xs:boolean" select="$prmIndexDataSeqDoc/*[@see => empty()][@seealso => empty()] => empty()"/>
        <xsl:variable name="isFirstSee" as="xs:boolean" select="$prmIndexDataSeqDoc/*[@id => string() eq $prmIndexData/@id => string()]/preceding-sibling::*[@see => exists()] => empty()"/>
        <xsl:variable name="hasOnlyOneSee" as="xs:boolean" select="$prmIndexDataSeqDoc/*[@see => exists()] => count() eq 1"/>
        <xsl:variable name="hasMultipleSee" as="xs:boolean" select="$hasOnlyOneSee => not()"/>
        <xsl:variable name="outputSeeWithSameLine" as="xs:boolean"  select="$indexTermDetailNotExists and $hasOnlyOneSee and $prmLevel eq 1"/>
        <xsl:variable name="outputSeeInAnotherLine" as="xs:boolean" select="$indexTermDetailNotExists and not($outputSeeWithSameLine) and $isFirstSee"/>
        
        <xsl:if test="$outputSeeInAnotherLine">
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($prmLevel)))"/>
                <xsl:if test="$shouldGenerateId">
                    <xsl:attribute name="id" select="$prmIndexData/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
                </xsl:if>
                <fo:inline><xsl:copy-of select="$prmIndexTermFo/*"/></fo:inline>
            </fo:block>
        </xsl:if>

        <xsl:variable name="seeKey" as="xs:string" select="$prmIndexData/@seekey => string()"/>
        <xsl:variable name="seeKeyId" as="xs:string" select="$seeKey => ahf:indexKeyToIdValue()"/>
        <xsl:variable name="seeFo" as="node()*" select="$prmIndexData/indexseefo/node()"/>

        <!-- Check see destination
             2021-05-23 t.makita
         -->
        <xsl:variable name="seeTargetIndexterm" as="element()*" select="key('indexDataByIndexKeyForSee', $seeKey, $indextermFinalSortedTree)"/>
        <xsl:if test="$seeTargetIndexterm => empty()">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes662,('%see-key'),(ahf:replace($seeKey,($indexKeySep),(':'))))"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- See entry as indented-->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(if ($outputSeeWithSameLine) then string($prmLevel) else string($prmLevel + 1)))"/>
            <xsl:if test="$outputSeeWithSameLine">
                <fo:inline>
                    <xsl:if test="$shouldGenerateId">
                        <xsl:attribute name="id" select="$prmIndexData/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
                    </xsl:if>
                    <xsl:copy-of select="$prmIndexTermFo/*"/>
                </fo:inline>
            </xsl:if>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeePrefix')"/>
                <xsl:value-of select="if ($outputSeeWithSameLine) then $cSeePrefixLevel1 else $cSeePrefixLevel2"/>
            </fo:inline>
            <xsl:choose>
                <xsl:when test="$pMakeSeeLink">
                    <fo:basic-link internal-destination="{$seeKeyId}">
                        <xsl:copy-of select="$seeFo"/>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline>
                        <xsl:copy-of select="$seeFo"/>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeeSuffix')"/>
                <xsl:value-of select="if ($outputSeeWithSameLine) then $cSeeSuffixLevel1 else $cSeeSuffixLevel2"/>
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
        <xsl:param name="prmLevel"        as="xs:integer" required="yes"/>
        
        <!-- SeeAlso key -->
        <xsl:variable name="seeAlsoKey" as="xs:string" select="$prmIndexData/@seealsokey => string()"/>
        <xsl:variable name="seeAlsoId"  as="xs:string" select="ahf:indexKeyToIdValue($seeAlsoKey)"/>
        <xsl:variable name="seeAlsoFo"  as="node()+" select="$prmIndexData/indexseealsofo/node()"/>

        <!-- Check see-also destination
             2021-05-23 t.makita
         -->
        <xsl:variable name="seeAlsoTargetIndexterm" as="element()*" select="key('indexDataByIndexKeyForSee', $seeAlsoKey, $indextermFinalSortedTree)"/>
        <xsl:if test="$seeAlsoTargetIndexterm => empty()">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes664,('%see-also-key'),(ahf:replace($seeAlsoKey,($indexKeySep),(':'))))"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- Output see-also block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($prmLevel + 1)))"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsSeeAlsoPrefix')"/>
                <xsl:value-of select="$cSeeAlsoPrefix"/>
            </fo:inline>
            <xsl:choose>
                <xsl:when test="$pMakeSeeLink">
                    <fo:basic-link internal-destination="{$seeAlsoId}">
                        <xsl:copy-of select="$seeAlsoFo"/>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline>
                        <xsl:copy-of select="$seeAlsoFo"/>
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
    
    <!-- function: indexDump template
	               Save $indextermOrigin, $indextermSorted and $indextermFinalSortedTree to file for debugging.
	     param: none
	     note:
	 -->
    <xsl:template name="indexDump">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="$stMes601"/>
        </xsl:call-template>
        
        <!-- $indexterm-origin.xml -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$',$documentLang,'-indexterm-origin.xml')}">
            <root>
                <xsl:copy-of select="$indextermOrigin"/>
            </root>
        </xsl:result-document>

        <!-- $indexterm-sorted.xml -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$',$documentLang,'-indexterm-sorted.xml')}">
            <root>
                <xsl:copy-of select="$indextermSorted"/>
            </root>
        </xsl:result-document>

        <!-- $indexterm-final-sorted-tree.xml -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$',$documentLang,'-indexterm-final-sorted-tree.xml')}">
            <root>
                <xsl:copy-of select="$indextermFinalSortedTree"/>
            </root>
        </xsl:result-document>

        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="$stMes602"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
