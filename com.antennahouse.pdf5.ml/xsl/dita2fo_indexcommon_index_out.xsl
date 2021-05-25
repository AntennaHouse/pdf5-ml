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
    
    <!-- Start level max value (Do not output any indexterm) -->
    <xsl:variable name="cStartLevelMax" as="xs:integer" select="9999"/>
    
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
    
    <!--    function: Get first level indexterm adjacent grouping key
            param:    prmIndexData
            return:   xs:string
            note:     Group by first indexterm key 
     -->
    <xsl:function name="ahf:getFirstIndexTermGroupKey" as="xs:string">
        <xsl:param name="prmIndexdata" as="element()"/>
        <xsl:sequence select="$prmIndexdata/indexterm[1]/@indexkeyForSee => string()"/>
    </xsl:function>
    
    <!--    function: Get second level indexterm adjacent grouping key
            param:    prmIndexData
            return:   xs:string
            note:     See below for keys
     -->
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
        <xsl:variable name="currentIndexKeyForSee" as="xs:string" select="$prmIndexData/@indexkeyForSee => string()"/>
        <xsl:variable name="precedingIndexData" as="element()?" select="$prmIndexDataGroupDoc/*[@id => string() eq $prmIndexData/@id => string()]/preceding-sibling::index-data[1]"/>
        <xsl:variable name="prevLevel" as="xs:integer" select="if ($precedingIndexData => exists()) then $precedingIndexData/@level => xs:integer() else 0"/>
        <xsl:variable name="prevIndexKeyForSee" as="xs:string" select="if ($precedingIndexData => exists()) then $precedingIndexData/@indexkeyForSee => string() else ''"/>
        
        <xsl:variable name="startLevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$currentLevel gt $prevLevel">
                    <!-- Level sequentially increased -->
                    <xsl:sequence select="$prevLevel + 1"/>
                </xsl:when>
                <xsl:when test="$currentLevel eq $prevLevel">
                    <xsl:choose>
                        <xsl:when test="$currentIndexKeyForSee eq $prevIndexKeyForSee">
                            <!-- Same category of index-see or index-see-also
                                 Don't output indexterm
                             -->
                            <xsl:sequence select="$cStartLevelMax"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Same level and different key --> 
                            <xsl:sequence select="ahf:getIndextermStartLevelFromPrev($prmIndexData, $prmIndexDataGroupDoc)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$currentLevel lt $prevLevel">
                    <xsl:choose>
                        <xsl:when test="$prevLevel eq 0">
                            <!-- Start of a group -->
                            <xsl:sequence select="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Beginning of new key
                                 Search relevant start level
                             -->
                            <xsl:sequence select="ahf:getIndextermStartLevelFromPrev($prmIndexData, $prmIndexDataGroupDoc)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$startLevel"/>
    </xsl:function>

    <!--    function: Get indexterm max start level
            param:    prmIndexData, prmIndexDataGroup
            return:   Start level of indexterm that can be obtained from prmIndexDataGroup
            note:     See $indextermSorted.xml in output folder by specifying debug.index="yes" in DITA-OT build.
    -->
    <xsl:function name="ahf:getIndextermStartLevelFromPrev" as="xs:integer">
        <xsl:param name="prmIndexData" as="element()"/>
        <xsl:param name="prmIndexDataGroupDoc" as="document-node()"/>
        
        <xsl:variable name="indexDataInGroup" as="element()" select="$prmIndexDataGroupDoc/*[@id => string() eq $prmIndexData/@id => string()]"/>
        <xsl:variable name="prevLowerLevel" as="xs:integer+">
            <xsl:for-each select="$prmIndexData/indexterm">
                <xsl:variable name="indexterm" as="element()" select="."/>
                <xsl:variable name="indexkeyForSee" as="xs:string" select="$indexterm/@indexkeyForSee => string()"/>
                <xsl:variable name="level" as="xs:integer" select="position()"/>
                <xsl:variable name="matchedPrevIndexData" as="element()?" select="$indexDataInGroup/preceding-sibling::index-data[child::indexterm[$level][@indexkeyForSee => string() eq $indexkeyForSee]][last()]"/>
                <xsl:if test="$matchedPrevIndexData => exists()">
                    <xsl:sequence select="$level"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="prevLowerIndexData" as="element()+">
            <xsl:for-each select="$prmIndexData/indexterm">
                <xsl:variable name="indexterm" as="element()" select="."/>
                <xsl:variable name="indexkeyForSee" as="xs:string" select="$indexterm/@indexkeyForSee => string()"/>
                <xsl:variable name="level" as="xs:integer" select="position()"/>
                <xsl:variable name="matchedPrevIndexData" as="element()?" select="$indexDataInGroup/preceding-sibling::index-data[child::indexterm[$level][@indexkeyForSee => string() eq $indexkeyForSee]][last()]"/>
                <xsl:if test="$matchedPrevIndexData => exists()">
                    <xsl:sequence select="$matchedPrevIndexData"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="prevLowerLevelMax" as="xs:integer" select="$prevLowerLevel => max()"/>
        <xsl:variable name="prevLowerLevelIndexPos" as="xs:integer" select="index-of($prevLowerLevel,$prevLowerLevelMax)[1]"/>
        <xsl:variable name="prevLowerLevelIndexData" as="element()" select="$prevLowerIndexData[$prevLowerLevelIndexPos]"/>
        <xsl:message select="'$prmIndexData/@indexkeyForSee=' || $prmIndexData/@indexkeyForSee => string()"/>
        <xsl:message select="'$prevLowerLevelMax=',$prevLowerLevelMax"/>
        <xsl:message select="'$prevLowerLevelIndexData=',$prevLowerLevelIndexData"/>
        <xsl:sequence select="$prevLowerLevelMax + 1"/>
    </xsl:function>


    <!--    function: Get significance of the indexterm group
            param:    prmIndexDataGroup
            return:   significanceNormal, significancePreferred
            note:     Significance is used in DocBook not in DITA
    -->
    <xsl:function name="ahf:getIndextermSignificance" as="xs:integer+">
        <xsl:param name="prmIndexDataGroupDoc" as="document-node()"/>
        <xsl:variable name="significancePreferred" as="xs:integer" select="$prmIndexDataGroupDoc/*[@significance => string() eq 'preferred'] => count()"/>
        <xsl:variable name="significanceNormal" as="xs:integer" select="$prmIndexDataGroupDoc/*[@significance => string() eq 'normal'] => count()"/>
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
        <xsl:variable name="isFirstOccurence" as="xs:boolean" select="$indextermSorted/*[@id => string() eq $prmIndexData/@id => string()][1]/preceding-sibling::index-data[@indexkeyForSee  => string() eq $currentIndexKeyForSee] => empty()"/>
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
        <xsl:param name="prmIndexData" as="element()" required="yes"/>
        <xsl:param name="prmStartLevel" as="xs:integer" required="yes"/>
        <xsl:param name="prmSignificance" as="xs:integer+" required="yes"/>
        <xsl:param name="prmShouldGenerateId" as="xs:boolean" required="yes"/>
        <xsl:param name="prmIsSeeIndexterm" as="xs:boolean" required="no" select="false()"></xsl:param>
        
        <xsl:variable name="currentLevel" as="xs:integer" select="$prmIndexData/@level => xs:integer()"/>
        <xsl:message select="'[outIndextermDetailLineImpl] $indexkeyForSee=' || $prmIndexData/@indexkeyForSee => string() ||' $prmStartLevel=' || $prmStartLevel => string() || ' $currentLevel=' || $currentLevel => string()"/>
        <xsl:for-each select="$prmIndexData/indexterm">
            <xsl:variable name="levelPosition" select="position()"/>
            <xsl:if test="$levelPosition ge $prmStartLevel">
                <xsl:variable name="indexterm" as="element()" select="."/>
                <xsl:variable name="indextermFO" as="node()+" select="$indexterm/indextermfo/node()"/>
                <xsl:variable name="indexKeyForSee" as="xs:string" select="$indexterm/@indexkeyForSee => string()"/>
                <xsl:choose>
                    <xsl:when test="$levelPosition lt $currentLevel">
                        <!-- This line is only indexterm title 
                             Do not set id for See, SeeAlso reference.
                          -->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($levelPosition)))"/>
                            <fo:inline><xsl:copy-of select="$indextermFO"/></fo:inline>
                        </fo:block>
                    </xsl:when>
                    <xsl:when test="$currentLevel eq $levelPosition">
                        <xsl:choose>
                            <xsl:when test="$prmIsSeeIndexterm">
                                <!-- Last indexterm of index-see -->
                                <fo:block>
                                    <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($levelPosition)))"/>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsIndexLineWoPageRef')"/>
                                    <fo:inline>
                                        <!-- Generate @id only when it is referenced via index-see or index-see-also
                                             2021-05-22 t.makita
                                          -->
                                        <xsl:if test="$prmShouldGenerateId">
                                            <xsl:attribute name="id">
                                                <xsl:value-of select="$indexterm/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="$indextermFO"/>
                                    </fo:inline>
                                </fo:block>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- This line is title and fo:index-citation-list for last indexterm -->
                                <fo:block>
                                    <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($levelPosition)))"/>
                                    <fo:inline>
                                        <!-- Generate @id only when it is referenced via index-see or index-see-also
                                             2021-05-22 t.makita
                                          -->
                                        <xsl:if test="$prmShouldGenerateId">
                                            <xsl:attribute name="id">
                                                <xsl:value-of select="$indexterm/@indexkeyForSee => string() => ahf:indexKeyToIdValue()"/>
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
                                            <xsl:variable name="preferredIndexKey" as="xs:string" select="$prmIndexData/@indexkey => string() || $indexKeySep ||$KEY_PREFERRED"/>
                                            <fo:index-key-reference ref-index-key="{$preferredIndexKey}"> 
                                                <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference atsIndexPreferred')"/>
                                            </fo:index-key-reference>
                                        </xsl:if>
                                        <xsl:if test="$prmSignificance[$cSignificanceNormal] gt 0">
                                            <xsl:variable name="normalIndexKey" as="xs:string" select="$prmIndexData/@indexkey => string()"/>
                                            <fo:index-key-reference ref-index-key="{$normalIndexKey}">
                                                <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference')"/>
                                            </fo:index-key-reference>
                                        </xsl:if>
                                    </fo:index-page-citation-list>
                                </fo:block>
                            </xsl:otherwise>
                        </xsl:choose>
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
            <xsl:with-param name="prmIsSeeIndexterm" select="true()"/>
        </xsl:call-template>

        <xsl:variable name="seeKey" as="xs:string" select="$prmIndexData/@seekey => string()"/>
        <xsl:variable name="seeKeyId" as="xs:string" select="$seeKey => ahf:indexKeyToIdValue()"/>
        <xsl:variable name="seeFO" as="node()*" select="$prmIndexData/indexseefo/node()"/>
    
        <xsl:message select="'[outSeeDetailLine] $seeKey=' || $seeKey || ' $startLevel=' || $startLevel => string()"/>

        <!-- Check see destination
             2021-05-23 t.makita
         -->
        <xsl:variable name="seeTargetIndexterm" as="element()*" select="key('indextermByIndexKeyForSee', $seeKey, $indextermSorted)"/>
        <xsl:if test="$seeTargetIndexterm => empty()">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes662,('%see-key'),($seeKey))"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- Level for index-see output -->
        <xsl:variable name="startLevlForSee" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$startLevel eq $cStartLevelMax">
                    <xsl:variable name="precedingIndexData" as="element()?" select="$prmFirstLevelIndexDataGroupDoc/*[@id => string() eq $prmIndexData/@id => string()]/preceding-sibling::index-data[1]"/>
                    <xsl:variable name="prevLevel" as="xs:integer" select="if ($precedingIndexData => exists()) then $precedingIndexData/@level => xs:integer() else 1"/>
                    <xsl:sequence select="$prevLevel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$startLevel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- See entry as indented-->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($startLevlForSee + 1)))"/>
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
        
        <!-- Output see-also block -->
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
