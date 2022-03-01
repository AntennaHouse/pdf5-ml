<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Generate fo:layout-master-set.
    Copyright © 2009-2011 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="ahf" 
>

    <!-- 
     function:	generate layout master set
     param:		none
     return:	fo:layout-master-set
     note:		none
    -->
    
    <xsl:template name="genLayoutMasterSet">
    	<fo:layout-master-set>
    		<xsl:call-template name="genSimplePageMaster"/>
    		<xsl:call-template name="genPageSequenceMaster"/>
    	</fo:layout-master-set>
    </xsl:template>
    
    <!-- 
     function:	generate simple-page master
     param:		none
     return:	fo:simple-page-master
     note:		none
    -->
    <xsl:template name="genSimplePageMaster">
        <xsl:call-template name="genSpmCover"/>
        <xsl:call-template name="genSpmCoverForPrint"/>
        <xsl:call-template name="genSpmFrontmatter"/>
        <xsl:call-template name="genSpmChapter"/>
        <xsl:call-template name="genSpmGlossaryList"/>
        <xsl:call-template name="genSpmIndex"/>
        <xsl:call-template name="genSpmBackmatter"/>
    </xsl:template>
    
    <xsl:template name="genSpmCover">
        <!-- Cover Page -->
        <fo:simple-page-master master-name="pmsCover">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCoverPage')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsCoverRegionBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsCoverBlank">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnCoverBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsCommonRegionBlankBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>
    
    </xsl:template>

    <xsl:template name="genSpmCoverForPrint">
        <!-- Cover Page for Print-->
        <fo:simple-page-master master-name="pmsCoverForPrint">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCoverPageForPrint')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsCoverRegionBodyForPrint')"/>
            </fo:region-body>
        </fo:simple-page-master>
    </xsl:template>

    <xsl:template name="genSpmFrontmatter">
        <!-- Front matter Page -->
        <fo:simple-page-master master-name="pmsFrontmatterLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBodyLeft')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnFrontmatterBeforeLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnFrontmatterAfterLeft">
                 <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start region-name="rgnFrontmatterStartLeft">
                 <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionStartLeft')"/>
            </fo:region-start>
            <fo:region-end>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionEndLeft')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsFrontmatterRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBodyRight')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnFrontmatterBeforeRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnFrontmatterAfterRight">
                 <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start>
                 <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionStartRight')"/>
            </fo:region-start>
            <fo:region-end   region-name="rgnFrontmatterEndRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionEndRight')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsFrontmatterBlankLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnFrontmatterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBlankBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>

        <fo:simple-page-master master-name="pmsFrontmatterBlankRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnFrontmatterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBlankBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>
        
        <xsl:if test="$pEnableLandscapePage">
            <fo:simple-page-master master-name="pmsFrontmatterLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBodyLeft')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnFrontmatterBeforeLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnFrontmatterAfterLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start region-name="rgnFrontmatterStartLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionStartLeft')"/>
                </fo:region-start>
                <fo:region-end>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionEndLeft')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsFrontmatterRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBodyRight')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnFrontmatterBeforeRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnFrontmatterAfterRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionStartRight')"/>
                </fo:region-start>
                <fo:region-end   region-name="rgnFrontmatterEndRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionEndRight')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsFrontmatterBlankLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnFrontmatterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBlankBodyLeft')"/>
                </fo:region-body>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsFrontmatterBlankRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsFrontmatterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnFrontmatterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBlankBodyRight')"/>
                </fo:region-body>
            </fo:simple-page-master>
        </xsl:if>

    </xsl:template>
    
    <xsl:template name="genSpmChapter">    
        <!-- Chapter Page -->
        <fo:simple-page-master master-name="pmsChapterLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBodyLeft')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnChapterBeforeLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnChapterAfterLeft">
                 <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start region-name="rgnChapterStartLeft">
                 <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionStartLeft')"/>
            </fo:region-start>
            <fo:region-end region-name="rgnChapterEndLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionEndLeft')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsChapterRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBodyRight')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnChapterBeforeRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnChapterAfterRight">
                 <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start>
                 <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionStartRight')"/>
            </fo:region-start>
            <fo:region-end region-name="rgnChapterEndRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionEndRight')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsChapterBlankLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnChapterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBlankBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>

        <fo:simple-page-master master-name="pmsChapterBlankRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnChapterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBlankBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>

        <xsl:if test="$pEnableLandscapePage">
            <fo:simple-page-master master-name="pmsChapterLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBodyLeft')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnChapterBeforeLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnChapterAfterLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start region-name="rgnChapterStartLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionStartLeft')"/>
                </fo:region-start>
                <fo:region-end region-name="rgnChapterEndLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionEndLeft')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsChapterRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBodyRight')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnChapterBeforeRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnChapterAfterRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionStartRight')"/>
                </fo:region-start>
                <fo:region-end region-name="rgnChapterEndRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionEndRight')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsChapterBlankLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnChapterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBlankBodyLeft')"/>
                </fo:region-body>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsChapterBlankRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsChapterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnChapterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBlankBodyRight')"/>
                </fo:region-body>
            </fo:simple-page-master>
        </xsl:if>

    </xsl:template>
    
    <xsl:template name="genSpmGlossaryList">
        <!-- Glossary list page -->
        <fo:simple-page-master master-name="pmsGlossaryListLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsGlossaryListPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionBodyLeft')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnGlossaryListBeforeLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnGlossaryListAfterLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start region-name="rgnGlossaryListLeftStart">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionStartLeft')"/>
            </fo:region-start>
            <fo:region-end>
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionEndLeft')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsGlossaryListRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsGlossaryListPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionBodyRight')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnGlossaryListBeforeRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnGlossaryListAfterRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start>
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionStartRight')"/>
            </fo:region-start>
            <fo:region-end region-name="rgnGlossaryListEndRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListRegionEndRight')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsGlossaryListBlankLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsGlossaryListPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnGlossaryListBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListBlankRegionBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>

        <fo:simple-page-master master-name="pmsGlossaryListBlankRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsGlossaryListPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnGlossaryListBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsGlossaryListBlankRegionBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>

    </xsl:template>
    
    <xsl:template name="genSpmIndex">
        <!-- Index page -->
        <fo:simple-page-master master-name="pmsIndexLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsIndexPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBodyLeft')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnIndexBeforeLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnIndexAfterLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start region-name="rgnIndexLeftStart">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionStartLeft')"/>
            </fo:region-start>
            <fo:region-end region-name="rgnIndexEndLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionEndLeft')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsIndexRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsIndexPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBodyRight')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnIndexBeforeRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnIndexAfterRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionStartRight')"/>
            </fo:region-start>
            <fo:region-end region-name="rgnIndexEndRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionEndRight')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsIndexBlankLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsIndexPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnIndexBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexBlankRegionBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>
        
        <fo:simple-page-master master-name="pmsIndexBlankRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsIndexPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnIndexBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexBlankRegionBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>
        
    </xsl:template>
    
    <xsl:template name="genSpmBackmatter">    
        <!-- Backmatter Page -->
        <fo:simple-page-master master-name="pmsBackmatterLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBodyLeft')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnBackmatterBeforeLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnBackmatterAfterLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start region-name="rgnBackmatterStartLeft">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionStartLeft')"/>
            </fo:region-start>
            <fo:region-end>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionEndLeft')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsBackmatterRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBodyRight')"/>
            </fo:region-body>
        	<fo:region-before region-name="rgnBackmatterBeforeRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBefore')"/>
            </fo:region-before>
        	<fo:region-after region-name="rgnBackmatterAfterRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter')"/>
            </fo:region-after>
        	<fo:region-start>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionStartRight')"/>
            </fo:region-start>
            <fo:region-end  region-name="rgnBackmatterEndRight">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionEndRight')"/>
            </fo:region-end>
        </fo:simple-page-master>
    
        <fo:simple-page-master master-name="pmsBackmatterBlankLeft">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageLeft')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnBackmatterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBlankBodyLeft')"/>
            </fo:region-body>
        </fo:simple-page-master>
        
        <fo:simple-page-master master-name="pmsBackmatterBlankRight">
            <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageRight')"/>
            <xsl:if test="$pOutputCropRegion">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
            </xsl:if>
            <fo:region-body region-name="rgnBackmatterBlankBody">
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBlankBodyRight')"/>
            </fo:region-body>
        </fo:simple-page-master>

        <xsl:if test="$pEnableLandscapePage">
            <fo:simple-page-master master-name="pmsBackmatterLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBodyLeft')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnBackmatterBeforeLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnBackmatterAfterLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start region-name="rgnBackmatterStartLeft">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionStartLeft')"/>
                </fo:region-start>
                <fo:region-end>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionEndLeft')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsBackmatterRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBodyRight')"/>
                </fo:region-body>
                <fo:region-before region-name="rgnBackmatterBeforeRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBefore')"/>
                </fo:region-before>
                <fo:region-after region-name="rgnBackmatterAfterRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter')"/>
                </fo:region-after>
                <fo:region-start>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionStartRight')"/>
                </fo:region-start>
                <fo:region-end  region-name="rgnBackmatterEndRight">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionEndRight')"/>
                </fo:region-end>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsBackmatterBlankLeftLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageLeftLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnBackmatterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBlankBodyLeft')"/>
                </fo:region-body>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="pmsBackmatterBlankRightLandscape">
                <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsBackmatterPageRightLandscape')"/>
                <xsl:if test="$pOutputCropRegion">
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCommonCropAndPrintMark')"/>
                </xsl:if>
                <fo:region-body region-name="rgnBackmatterBlankBody">
                    <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBlankBodyRight')"/>
                </fo:region-body>
            </fo:simple-page-master>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	generate page-sequence master
     param:		none
     return:	fo:page-sequence-master
     note:		
    -->
    <xsl:template name="genPageSequenceMaster">
        <xsl:call-template name="genPsmCover"/>
        <xsl:call-template name="genPsmCoverForPrint"/>
        <xsl:call-template name="genPsmFrontmatter"/>
        <xsl:call-template name="genPsmChapter"/>
        <xsl:call-template name="genPsmGlossaryList"/>
        <xsl:call-template name="genPsmIndex"/>
        <xsl:call-template name="genPsmBackmatter"/>
    </xsl:template>
    
    <xsl:template name="genPsmCover">
        <!-- Cover -->
        <fo:page-sequence-master master-name="pmsPageSeqCover">
        	<fo:repeatable-page-master-alternatives>
        		<fo:conditional-page-master-reference master-reference="pmsCover" 
                                                      odd-or-even="any" 
                                                      page-position="any"
                                                      blank-or-not-blank="not-blank"/>
        		<fo:conditional-page-master-reference master-reference="pmsCoverBlank" 
                                                      odd-or-even="any"  
                                                      page-position="any"
                                                      blank-or-not-blank="blank"/>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </xsl:template>

    <xsl:template name="genPsmCoverForPrint">
        <!-- Cover For Print-->
        <fo:page-sequence-master master-name="pmsPageSeqCoverForPrint">
            <fo:single-page-master-reference master-reference="pmsCoverForPrint"/>
        </fo:page-sequence-master>
    </xsl:template>

    <xsl:template name="genPsmFrontmatter">
        <!-- Front matter -->
        <fo:page-sequence-master master-name="pmsPageSeqFrontmatter">
        	<fo:repeatable-page-master-alternatives>
        	    <xsl:choose>
        	        <xsl:when test="$pIsWebOutput">
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:when>
        	        <xsl:otherwise>
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:otherwise>
        	    </xsl:choose>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>

        <xsl:if test="$pEnableLandscapePage">
            <fo:page-sequence-master master-name="pmsPageSeqFrontmatterLandscape">
                <fo:repeatable-page-master-alternatives>
                    <xsl:choose>
                        <xsl:when test="$pIsWebOutput">
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterRightLandscape" 
                                odd-or-even="any"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankRightLandscape" 
                                odd-or-even="any"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterRightLandscape" 
                                odd-or-even="odd"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsFrontmatterBlankRightLandscape" 
                                odd-or-even="odd"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="genPsmChapter">
        <!-- Chapter -->
        <fo:page-sequence-master master-name="pmsPageSeqChapter">
        	<fo:repeatable-page-master-alternatives>
        	    <xsl:choose>
        	        <xsl:when test="$pIsWebOutput">
        	            <fo:conditional-page-master-reference master-reference="pmsChapterRight" 
        	                odd-or-even="any" 
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsChapterBlankRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:when>
        	        <xsl:otherwise>
        	            <fo:conditional-page-master-reference master-reference="pmsChapterLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsChapterRight" 
        	                odd-or-even="odd" 
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsChapterBlankLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsChapterBlankRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:otherwise>
        	    </xsl:choose>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>

        <xsl:if test="$pEnableLandscapePage">
            <fo:page-sequence-master master-name="pmsPageSeqChapterLandscape">
                <fo:repeatable-page-master-alternatives>
                    <xsl:choose>
                        <xsl:when test="$pIsWebOutput">
                            <fo:conditional-page-master-reference master-reference="pmsChapterRightLandscape" 
                                odd-or-even="any" 
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsChapterBlankRightLandscape" 
                                odd-or-even="any"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:conditional-page-master-reference master-reference="pmsChapterLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsChapterRightLandscape" 
                                odd-or-even="odd" 
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsChapterBlankLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsChapterBlankRightLandscape" 
                                odd-or-even="odd"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
        </xsl:if>
        

    </xsl:template>
    
    <xsl:template name="genPsmGlossaryList">
        <!-- Glossary list -->
        <fo:page-sequence-master master-name="pmsPageSeqGlossaryList">
        	<fo:repeatable-page-master-alternatives>
        	    <xsl:choose>
        	        <xsl:when test="$pIsWebOutput">
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListBlankRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:when>
        	        <xsl:otherwise>
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListBlankLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsGlossaryListBlankRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:otherwise>
        	    </xsl:choose>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </xsl:template>
    
    <xsl:template name="genPsmIndex">
        <!-- Index -->
        <fo:page-sequence-master master-name="pmsPageSeqIndex">
        	<fo:repeatable-page-master-alternatives>
        	    <xsl:choose>
        	        <xsl:when test="$pIsWebOutput">
        	            <fo:conditional-page-master-reference master-reference="pmsIndexRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsIndexBlankRight" 
        	                odd-or-even="any" 
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:when>
        	        <xsl:otherwise>
        	            <fo:conditional-page-master-reference master-reference="pmsIndexLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsIndexRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsIndexBlankLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsIndexBlankRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:otherwise>
        	    </xsl:choose>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </xsl:template>
    
    <xsl:template name="genPsmBackmatter">
        <!-- Backmatter -->
        <fo:page-sequence-master master-name="pmsPageSeqBackmatter">
        	<fo:repeatable-page-master-alternatives>
        	    <xsl:choose>
        	        <xsl:when test="$pIsWebOutput">
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankRight" 
        	                odd-or-even="any"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:when>
        	        <xsl:otherwise>
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="not-blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankLeft" 
        	                odd-or-even="even"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankRight" 
        	                odd-or-even="odd"  
        	                page-position="any"
        	                blank-or-not-blank="blank"/>
        	        </xsl:otherwise>
        	    </xsl:choose>
        	</fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>

        <xsl:if test="$pEnableLandscapePage">
            <fo:page-sequence-master master-name="pmsPageSeqBackmatterLandscape">
                <fo:repeatable-page-master-alternatives>
                    <xsl:choose>
                        <xsl:when test="$pIsWebOutput">
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterRightLandscape" 
                                odd-or-even="any"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankRightLandscape" 
                                odd-or-even="any"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterRightLandscape" 
                                odd-or-even="odd"  
                                page-position="any"
                                blank-or-not-blank="not-blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankLeftLandscape" 
                                odd-or-even="even"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                            <fo:conditional-page-master-reference master-reference="pmsBackmatterBlankRightLandscape" 
                                odd-or-even="odd"  
                                page-position="any"
                                blank-or-not-blank="blank"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
