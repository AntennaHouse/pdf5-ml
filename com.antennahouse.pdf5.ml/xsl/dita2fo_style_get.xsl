<?xml version="1.0" encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Stylesheet for getting variable & style.
    Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahp="http://www.antennahouse.com/names/XSLT/Document/PageControl"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:style="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs style"
    >
    <!--============================================
	     External dependencies:
	     $documentLang (dita2fo_global.xsl)
	     $pPaperSize (dita2fo_param.xsl)
	     $pOutputType (dita2fo_param.xsl)
	    ============================================-->
    
    <!-- Default parameter
         This value should be specified according to the user customization.
         $defaultDocType: any document type string such as "UM" (User's manual), "IM" (Installation manual)
         $defaultPaperSize: any paper size such as "A4", "B5"
         $defaultOutputType: any output condition such as "print-color", "print-mono", "web"
     -->
    <xsl:variable name="defaultXmlLang" as="xs:string" select="ahf:nomalizeXmlLang($documentLang)"/>
    <xsl:variable name="defaultDocType" as="xs:string?" select="()"/>
    <xsl:variable name="defaultPaperSize" as="xs:string?" select="$pPaperSize"/>
    <xsl:variable name="defaultOutputType" as="xs:string?" select="$pOutputType"/>
    
    <!-- root variables -->
    <xsl:variable name="rootXmlLang" as="xs:string" select="$defaultXmlLang"/>
    <xsl:variable name="rootStyle" as="xs:string" select="'atsRoot'"/>
    
    <!-- inline XSL-FO properties -->
    <xsl:variable name="inlineXslFoPorpperties" as="xs:string+" 
                  select="('font-family',
                           'font-size',
                           'font-stretch',
                           'font-size-adjust',
                           'font-style',
                           'font-variant',
                           'font-weight',
                           'alignment-adjust',
                           'alignment-baseline',
                           'baseline-shift',
                           'color',
                           'dominant-baseline',
                           'line-height',
                           'text-decoration',
                           'country',
                           'language',
                           'script',
                           'hyphenate',
                           'hyphenation-character',
                           'hyphenation-push-character-count',
                           'hyphenation-remain-character-count'
                            )"/>
    <!--xsl:variable name="inlineXslFoPorpperties" as="xs:string+" 
                  select="('font-family',
                           'font-selection-strategy',
                           'font-size',
                           'font-stretch',
                           'font-size-adjust',
                           'font-style',
                           'font-variant',
                           'font-weight',
                           'margin-top',
                           'margin-bottom',
                           'margin-left',
                           'margin-right',
                           'space-end',
                           'space-start',
                           'top',
                           'right',
                           'bottom',
                           'left',
                           'relative-position',
                           'alignment-adjust',
                           'alignment-baseline',
                           'baseline-shift',
                           'block-progression-dimension',
                           'color',
                           'dominant-baseline',
                           'height',
                           'inline-progression-dimension',
                           'keep-together.within-line',
                           'keep-with-next.within-line',
                           'keep-with-previous.within-line',
                           'line-height',
                           'text-decoration',
                           'visibility',
                           'width',
                           'wrap-option'
                            )"/-->
    
    <!-- default template for getting style -->
    <xsl:template match="*" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="()"/>
    </xsl:template>

    <xsl:template match="dita-merge" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="$rootStyle"/>
    </xsl:template>
    
    <!-- For temporary tree -->
    <xsl:template match="document-node()" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:choose>
            <xsl:when test="empty(child::dita-merge)">
                <xsl:sequence select="$rootStyle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- We cannot decide topic/title or topiref/topicmeta/navtitle style in normal way. -->
    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:param name="prmTopicTitleStyle" tunnel="yes" as="xs:string?" required="no" select="()"/>
        <xsl:sequence select="$prmTopicTitleStyle"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')]/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:param name="prmNavTitleStyle" tunnel="yes" as="xs:string?" required="no" select="()"/>
        <xsl:sequence select="$prmNavTitleStyle"/>
    </xsl:template>

    <!-- 
         getAttributeSetWithLang template
         function: Get attribute-set associated with $prmElem.
         parameter: prmAttrSetName: Attributeset name
                    prmElem: Element in document.
                    prmDocType: Document type.
                    prmPaperSize: Paper size.
                    prmOutputType: Output type.
                    prmDoInherit: Inherit style even when $prmAttrSetName is specified
                    prmRequiredProperty: Required property from caller side
         notes: This template will be called in the following manner:
         
                 <xsl:template match="p">
                     <fo:block>
                       <xsl:call-template name="getAttributeSetWithElem"/>
                     </fo:block>
                 </xsl:template>
                 
                Also the corresponding "p" element must implememt following 
                template that returns style names (attribute-set name).
                
                <xsl:template match="p" mode="MODE_GET_STYLE" as="xs:string+">
                  <xsl:sequence select="'atsP'"/>
                </xsl:template>
      -->
    <xsl:template name="getAttributeSetWithLang" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string?" required="no" select="()"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmDoInherit" as="xs:boolean" required="no" select="false()"/>
        <xsl:param name="prmRequiredProperty" tunnel="yes" as="xs:string*" required="no" select="()"/>
        
        <xsl:variable name="curXmlLang" as="xs:string" select="ahf:getCurrentXmlLang($prmElem)"/>
        
        <!-- Style names that correspond to $prmElem or $prmAttrSetName itself -->
        <xsl:variable name="styles" as="xs:string*">
            <xsl:choose>
                <xsl:when test="empty($prmAttrSetName)">
                    <xsl:apply-templates select="$prmElem" mode="MODE_GET_STYLE"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$prmAttrSetName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Inherited style sequence -->
        <xsl:variable name="inheritedStyles" as="xs:string*">
            <xsl:choose>
                <xsl:when test="ahf:isXmlLangChanged($prmElem) and (empty($prmAttrSetName) or (exists($prmAttrSetName) and $prmDoInherit))">
                    <xsl:call-template name="ahf:getAncestorStyleNames">
                        <xsl:with-param name="prmElem" select="$prmElem"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- attributes for $prmElem -->
        <xsl:variable name="attsForElem" as="attribute()*">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="string-join($styles,' ')"/>
                <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Inherited attributes -->
        <xsl:variable name="attsInherited" as="attribute()*">
            <xsl:choose>
                <xsl:when test="exists($inheritedStyles)">
                    <xsl:call-template name="getAttributeSet">
                        <xsl:with-param name="prmAttrSetName" select="string-join($inheritedStyles,' ')"/>
                        <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
                        <xsl:with-param name="prmDocType" select="$prmDocType"/>
                        <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                        <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Combine attributes -->
        <xsl:variable name="resultAtts" as="attribute()*">
            <xsl:choose>
                <xsl:when test="empty($prmRequiredProperty)">
                    <xsl:sequence select="ahf:filterAttrs($attsInherited,$inlineXslFoPorpperties)"/>
                    <xsl:sequence select="$attsForElem"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:filterAttrs($attsInherited,$prmRequiredProperty)"/>
                    <xsl:sequence select="ahf:filterAttrs($attsForElem,$prmRequiredProperty)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!--xsl:sequence select="$resultAtts"/-->
        <xsl:for-each select="$resultAtts">
            <xsl:attribute name="{name()}" select="string(.)"/>
        </xsl:for-each>

        <!--xsl:message select="'$inheritedStyles=',$inheritedStyles"/>
        <xsl:message select="'$styles=',$styles"/>
        <xsl:message select="'$attsForElem=',$attsForElem"/>
        <xsl:message select="'$attsInherited=',$attsInherited"/-->
    </xsl:template>

    <!-- 
        ahf:getCurrentXmlLang function
        function: Get current xml:lang as string
        parameter: prmElem
        notes: Refers to $map/@xml:lang when $prmElem belongs topic.
               BugFix: Complement $rootXmlLang when $map/xml:lang is absent.
               2015-09-01 t.makita
     -->
    <xsl:function name="ahf:getCurrentXmlLang" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="tempXmlLangSeq" as="xs:string+">
            <xsl:choose>
                <xsl:when test="$prmElem/ancestor-or-self::*[contains(@class,' topic/topic ')]">
                    <xsl:sequence select="$rootXmlLang"/>
                </xsl:when>
                <xsl:when test="empty($map/@xml:lang)">
                    <xsl:sequence select="$rootXmlLang"/>
                </xsl:when>
            </xsl:choose>
            <xsl:for-each select="$prmElem/ancestor-or-self::*/@xml:lang">
                <xsl:sequence select="ahf:nomalizeXmlLang(string(.))"/>    
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$tempXmlLangSeq[last()]"/>
    </xsl:function>

    <!-- 
         ahf:isXmlLangChanged function
         function: Return true() is xml:lang has been changed from the nearest ancestor xml:lang.
         parameter: prmElem: Current document element.
         notes: BugFix: Complement $rootXmlLang when $map/xml:lang is absent.
                2015-09-01 t.makita
      -->
    <xsl:function name="ahf:isXmlLangChanged" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <!--xsl:variable name="curXmlLang" as="xs:string?" select="if (exists($prmElem/@xml:lang)) then ahf:nomalizeXmlLang(string($prmElem/@xml:lang)) else ()"/-->
        <xsl:variable name="ancestorOrSelfXmlLang" as="xs:string+">
            <xsl:choose>
                <xsl:when test="$prmElem/ancestor-or-self::*[contains(@class,' topic/topic ')]">
                    <xsl:sequence select="$rootXmlLang"/>
                </xsl:when>
                <xsl:when test="empty($map/@xml:lang)">
                    <xsl:sequence select="$rootXmlLang"/>
                </xsl:when>
            </xsl:choose>
            <xsl:for-each select="$prmElem/ancestor-or-self::*/@xml:lang">
                <xsl:sequence select="ahf:nomalizeXmlLang(string(.))"/>
            </xsl:for-each>
        </xsl:variable>
        <!--xsl:message select="'$prmElem=',$prmElem"/>
        <xsl:message select="'$ancestorOrSelfXmlLang=',$ancestorOrSelfXmlLang"/-->
        <xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="count($ancestorOrSelfXmlLang) gt 1">
                    <xsl:sequence select="$ancestorOrSelfXmlLang[last() - 1] ne $ancestorOrSelfXmlLang[last()]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>

    <!-- 
         ahf:getAncestStyleNames template
         function:  Return ancestor style names from $prmElem.
         parameter: prmElem: Current document elemenmt.
         notes:     Temporary solution ⇒ add document-node() to handle glossentry temporary tree.
      -->
    <xsl:template name="ahf:getAncestorStyleNames" as="xs:string+">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="style" as="xs:string*">
            <xsl:for-each select="$prmElem/ancestor::*|$prmElem/ancestor::document-node()">
                <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$style"/>
        <xsl:if test="$pDebug">
            <xsl:message select="'ahf:getAncestorStyleNames()=',$style"/>
        </xsl:if>
    </xsl:template>

    <!-- 
         ahf:filterAttrs function
         function: Return attribute filtered by $prmFilter.
         parameter: prmAtts: attribute()*
                    prmFilter: xs:string+ filter attribute name
         notes: 
      -->
    <xsl:function name="ahf:filterAttrs" as="attribute()*">
        <xsl:param name="prmAttrs" as="attribute()*"/>
        <xsl:param name="prmFilter" as="xs:string+"/>
        <xsl:for-each select="$prmAttrs">
            <xsl:variable name="att" as="attribute()" select="."/>
            <xsl:if test="name($att) = $prmFilter">
                <xsl:sequence select="$att"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <!-- 
         getAttributeSet template
         function: Get attribute-set specified by $prmAttrSetName.
         parameter: prmAttrSetName: Attributeset name (Can be specified multiple names by delimiting using white-space.
                    prmXmlLang: Language code
                    prmDocType: Document type.
                    prmPaperSize: Paper size.
         notes:     $glStyleDefs/* has @xml:lang attributes certanly.
                    ahf:getAttributeSet is used to get style in context free mode and use $map/@xml:lang for $prmXmlLang
                    parameter.
      -->
    <xsl:function name="ahf:getAttributeSet" as="attribute()*">
        <xsl:param name="prmAttrSetname" as="xs:string"/>
        <xsl:call-template name="getAttributeSet">
            <xsl:with-param name="prmAttrSetName" select="$prmAttrSetname"/>
        </xsl:call-template>
    </xsl:function>
        
    <xsl:template name="getAttributeSet" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="normalizedAtrSetName" select="normalize-space($prmAttrSetName)"/>
        <xsl:for-each select="tokenize($normalizedAtrSetName, '[\s]+')">
            <xsl:variable name="attrSetName" select="string(.)"/>
            <xsl:variable name="attrSetElements" as="element()*" select="$glStyleDefs/*[string(@name) eq $attrSetName][string(@xml:lang) eq string($prmXmlLang)]"/>
            <xsl:if test="empty ($attrSetElements)">
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes">
                        <xsl:value-of select="ahf:replace($stMes005,('%attrsetname','%file'),($attrSetName,$allStyleDefFile))"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <!-- Get attribute from looser condition. 
                 Attributes are returned from first to last.
                 If there is N'th conditions, there are 2**N th patterns are needed.
             -->
            <!-- Matches only xml:lang -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[empty(@doc-type)]
                                                           [empty(@paper-size)]
                                                           [empty(@output-type)]
                                                            "/>
            </xsl:call-template>
            <!-- Matches only doc-type -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                                                           [exists(@doc-type)]
                                                           [empty(@paper-size)]
                                                           [empty(@output-type)]
                                                           "/>
            </xsl:call-template>
            <!-- Matches only paper-size -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                    			select="$attrSetElements[empty(@doc-type)]
                    			                           [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
									                       [exists(@paper-size)]
									                       [empty(@output-type)]
									                       "/>
            </xsl:call-template>
            <!-- Matches only output-type -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[empty(@doc-type)]
                                                           [empty(@paper-size)]
                                                           [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                                                           [exists(@output-type)]
                                                           "/>
            </xsl:call-template>
            <!-- Matches doc-type and paper-size -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                                                           [exists(@doc-type)]
                                                           [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                                                           [exists(@paper-size)]
                                                           [empty(@output-type)]
                                                           "/>
            </xsl:call-template>
            <!-- Matches doc-type and output-type -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                                                           [exists(@doc-type)]
                                                           [empty(@paper-size)]
                                                           [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                                                           [exists(@output-type)]
                                                           "/>
            </xsl:call-template>
            <!-- Matches paper-size and output-type -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[empty(@doc-type)]
                                                           [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                                                           [exists(@paper-size)]
                                                           [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                                                           [exists(@output-type)]
                                                           "/>
            </xsl:call-template>
            <!-- Matches doc-type, paper-size and output-type -->
            <xsl:call-template name="getAttributeInner">
                <xsl:with-param name="prmAttrSetElement" 
                                select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                                                           [exists(@doc-type)]
                                                           [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                                                           [exists(@paper-size)]
                                                           [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                                                           [exists(@output-type)]
                                                           "/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- 
         getAttributeInner template
         function: return attribute()* from $prmAttrSetElem
         parameter: prmAttrSetElem: Childlen of $glStyleDefs
         notes: 
      -->
    <xsl:template name="getAttributeInner" as="attribute()*">
        <xsl:param name="prmAttrSetElement" as="element()*"/>
        <xsl:for-each select="$prmAttrSetElement">
            <xsl:for-each select="./*[1]/@*">
                <xsl:attribute name="{name()}" select="string(.)"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- 
         getAttributeSetAsCssWithLang template
         function: Get attributes specified by $prmAttrSetName as CSS notation
         parameter: prmAttrSetName: attribute-set name
                    prmElem: Element in document.
                    prmDocType: document-type
                    prmPaperSize: paper-size
         note: Call getAttributeSetWithLang internally and cnvert it CSS style.
    -->
    <xsl:template name="getAttributeSetAsCssWithLang" as="xs:string">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="attrsResult">
            <dummy>
                <xsl:copy-of select="$attrs"/>
            </dummy>
        </xsl:variable>
        <xsl:sequence select="ahf:attributeToCss($attrsResult/*[1]/@*)"/>
    </xsl:template>
    
    <!-- 
         attributeSetToCss function
         function: Convert attributes to CSS notation
         parameter: prmAttributes: attribute()*
         note: This function does not handle axf namespace attributes
               because it is intended for instream object.
    -->
    <xsl:function name="ahf:attributeToCss" as="xs:string">
        <xsl:param name="prmAttributes" as="attribute()*"/>
        
        <xsl:variable name="first" select="subsequence($prmAttributes,1,1)" as="attribute()*"/>
        <xsl:variable name="restString" select="if (empty(subsequence($prmAttributes,2))) then '' else  (ahf:attributeToCss(subsequence($prmAttributes,2)))" as="xs:string"/>
        
        <xsl:variable name="firstString">
            <xsl:choose>
                <xsl:when test="empty($first)">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="name" select="name($first)"/>
                    <xsl:variable name="value" select="string($first)"/>
                    <xsl:value-of select="$name"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="$value"/>
                    <xsl:text>;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="concat($firstString, $restString)"/>
    </xsl:function>

    <!-- 
     function:	getAttibuteSetWithPageVariables
     param:		prmAttrSetName
     return:	attribute()*
     note:		Get attribute considering paper width/height, crop size horizontal/vertical, bleed size
    -->
    <xsl:function name="ahf:getAttributeSetWithPageVariables" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string"/>
        <xsl:variable name="src" as="xs:string+" select="('%paper-width','%paper-height','%crop-size-h','%crop-size-v','%bleed-size')"/>
        <xsl:variable name="dst" as="xs:string+" select="($pPaperWidth,$pPaperHeight,$pCropSizeH,$pCropSizeV,$pBleedSize)"/>
        <xsl:variable name="attrs" as="attribute()*" select="ahf:getAttributeSetReplacing($prmAttrSetName,$src,$dst)"/>
        <xsl:sequence select="$attrs"/>
    </xsl:function>
    
    <xsl:function name="ahf:getAttributeWithPageVariables" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string"/>
        <xsl:param name="prmAttributeName" as="xs:string"/>
        <xsl:variable name="src" as="xs:string+" select="('%paper-width','%paper-height','%crop-size-h','%crop-size-v','%bleed-size')"/>
        <xsl:variable name="dst" as="xs:string+" select="($pPaperWidth,$pPaperHeight,$pCropSizeH,$pCropSizeV,$pBleedSize)"/>
        <xsl:variable name="attrs" as="attribute()*" select="ahf:getAttributeSetReplacing($prmAttrSetName,$src,$dst)"/>
        <xsl:sequence select="$attrs[name() eq $prmAttributeName]"/>
    </xsl:function>
    

    <!-- 
         getAttributeSetReplacing template
         function: Get attributes specified by $prmAttrSetName replacing $prmSrc by $prmDst.
         parameter: prmAttrSetName: attribute-set name (space delimitored)
                    prmXml:lang: xml:lang
                    prmDocType: document-type
                    prmPaperSize: paper-size
                    prmSrc: source string 
                    prmDst: destination string
         note: The count of $prmSrc and $prmDst must be the same.
               Example:
               Define following attribute.
               <attribute name="top">$index_1_top + $index_1_height + (0.7mm * %n) + ($index_2_height * (%n - 1))</attribute>
               Call this template:
               <xsl:call-template name="getAttributeSetReplacing">
                 <xsl:with-param name="prmAttrSetName" select="'...'"/>
                 <xsl:with-param name="prmSrc" select="('%n')"/>
                 <xsl:with-param name="prmDst" select="('1')"/>
               </xsl:call-template>
              This will result following attribute
              <xsl:attribute name="height">$index_1_top + $index_1_height + (0.7mm * 1) + ($index_2_height * (1 - 1))</xsl:attribute>
              $index_1_top,$index_1_height,$index_2_height will be replaced by the actual variable value.
      -->
    <xsl:function name="ahf:getAttributeSetReplacing" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="xs:string+"/>
        <xsl:call-template name="getAttributeSetReplacing">
            <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
            <xsl:with-param name="prmSrc" select="$prmSrc"/>
            <xsl:with-param name="prmDst" select="$prmDst"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:template name="getAttributeSetReplacing" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmSrc" as="xs:string+" required="yes"/>
        <xsl:param name="prmDst" as="xs:string+" required="yes"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:for-each select="$attrs">
            <xsl:variable name="att" as="attribute()" select="."/>
            <xsl:attribute name="{name($att)}">
                <xsl:value-of select="ahf:replace(string($att),$prmSrc,$prmDst)"/>
            </xsl:attribute>
        </xsl:for-each>
        
    </xsl:template>

    <!-- 
         getAttribute template
         function: Get attribute specified by $prmAttrName from attribute-set specified by $prmAttrSetName.
         parameter：prmAttrSetName：An attribute name
                    prmAttrName：Attribute name
         note: You can specify multiple attribute name in $prmAttrName delimitering by white-space.
      -->
    <xsl:function name="ahf:getAttribute" as="attribute()?">
        <xsl:param name="prmAttrSetName" as="xs:string"/>
        <xsl:param name="prmAttrName" as="xs:string+"/>
        <xsl:call-template name="getAttribute">
            <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
            <xsl:with-param name="prmAttrName" select="$prmAttrName"/>
        </xsl:call-template>
        
    </xsl:function>

    <xsl:template name="getAttribute" as="attribute()*">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmAttrName" as="xs:string+" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="normalizedAttrName" select="normalize-space($prmAttrName)"/>
        <xsl:for-each select="tokenize($normalizedAttrName, '[\s]+')">
            <xsl:variable name="attrName" select="string(.)"/>
            <xsl:if test="empty($attrs[name() eq $attrName])">
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes">
                        <xsl:value-of select="ahf:replace($stMes006,('%attrname','%attrsetname','%file'),($attrName,$prmAttrSetName,$allStyleDefFile))"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:variable name="attr" as="attribute()" select="$attrs[name() eq $attrName][position() eq last()]"/>
            <xsl:attribute name="{name($attr)}" select="string($attr)"/>
            <xsl:if test="$pDebug">
                <xsl:message select="concat('[getAttribute] attribute-name=',name($attr),' value=',string($attr))"/>
            </xsl:if>
        </xsl:for-each>

    </xsl:template>

    <!-- 
         getAttributeAs template
         function: Get attribute specified by $prmAttrName in attribute-set $prmAttrSetName as attribute name $prmAltAttrName.
         parameter：prmAttrSetName: An attribute-set name
                    prmAttrName: An attribute name
                    prmAltAttrName: The alternate attribute name
         note: 
      -->
    <xsl:template name="getAttributeAs" as="attribute()?">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmAttrName" as="xs:string" required="yes"/>
        <xsl:param name="prmAltAttrName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="empty($attrs[name() eq $prmAttrName])">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes006,('%attrname','%attrsetname','%file'),($prmAttrName,$prmAttrSetName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="attr" as="attribute()" select="$attrs[name() eq $prmAttrName][position() eq last()]"/>
        <xsl:attribute name="{$prmAltAttrName}" select="string($attr)"/>
        <xsl:if test="$pDebug">
            <xsl:message select="concat('[getAttributeAs]      attribute-name=',$prmAltAttrName,' value=',string($attr))"/>
        </xsl:if>
    </xsl:template>

    <!-- 
         getAttributeValue template
         function: Get attribute value from attribute-set specified by $prmAttrSetName and attribute name specified by $prmAttrName as xs:string．
         parameter: prmAttrSetName: attribute-set name
                    prmAttrName: attribute name
                    prmXmlLang: Language code
                    prmDocType: Document type
                    prmPaperSize: Paper size
                    prmOutputType: Output type.
         notes: 
      -->
    <xsl:function name="ahf:getAttributeValue" as="xs:string">
        <xsl:param name="prmAttrSetName" as="xs:string"/>
        <xsl:param name="prmAttrName" as="xs:string"/>
        <xsl:call-template name="getAttributeValue">
            <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
            <xsl:with-param name="prmAttrName" select="$prmAttrName"/>
        </xsl:call-template>
    </xsl:function>

    <xsl:template name="getAttributeValue" as="xs:string">
        <xsl:param name="prmAttrSetName" as="xs:string" required="yes"/>
        <xsl:param name="prmAttrName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="empty($attrs[name() eq $prmAttrName])">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes007,('%attrname','%attrsetname','%file'),($prmAttrName,$prmAttrSetName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="attr" select="$attrs[name() eq $prmAttrName][position() eq last()]"/>
        <xsl:sequence select="string($attr)"/>
        <xsl:if test="$pDebug">
            <xsl:message select="concat('[getAttributeValue]   attribute-name=',name($attr),' value=',string($attr))"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="getAttributeValueWithLang" as="xs:string">
        <xsl:param name="prmAttrSetName" as="xs:string?" required="no" select="()"/>
        <xsl:param name="prmAttrName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="attrs" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="$prmAttrSetName"/>
                <xsl:with-param name="prmElem" select="$prmElem"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="empty($attrs[name() eq $prmAttrName])">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes007,('%attrname','%attrsetname','%file'),($prmAttrName,$prmAttrSetName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="attr" select="$attrs[name() eq $prmAttrName][position() eq last()]"/>
        <xsl:sequence select="string($attr)"/>
        <xsl:if test="$pDebug">
            <xsl:message select="concat('[getAttributeValue]   attribute-name=',name($attr),' value=',string($attr))"/>
        </xsl:if>
    </xsl:template>

    <!-- 
         getVarValueWithLang template
         function: Get variable specified by $prmVarName considering $prmElem/@xml:lang as key.
         parameter: prmVarName: An variable name
                    prmElem: The relevant element
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: This template get @xml:lang from $prmElem/ancestor-or-self::* and 
               return the specific variable value associated with @xml:lang.
      -->
    <xsl:template name="getVarValueWithLang" as="xs:string">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="curXmlLang" as="xs:string" select="ahf:getCurrentXmlLang($prmElem)"/>
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="$prmVarName"/>
            <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
            <xsl:with-param name="prmDocType" select="$prmDocType"/>
            <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
        </xsl:call-template>
    </xsl:template>    

    <!-- 
         getVarValue template
         function: Get variable value specified by $prmVarName, $prmXmlLang, $prmDocType, $prmPaperSize.
         parameter: prmVarName：Variable name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:function name="ahf:getVarValue" as="xs:string">
        <xsl:param name="prmVarName" as="xs:string"/>
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="$prmVarName"/>
            <xsl:with-param name="prmXmlLang" select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType" select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize" select="$defaultPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$defaultOutputType"/>
        </xsl:call-template>
    </xsl:function>

    <xsl:template name="getVarValue" as="xs:string">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <!--xsl:message select="'[getVarValue] $prmVarName=',$prmVarName"/>
        <xsl:message select="'[getVarValue] $prmXmlLang=',$prmXmlLang"/-->
        <xsl:variable name="vars" as="element()*" select="$glVarDefs/*[string(@name) eq $prmVarName]"/>
        <xsl:if test="empty($vars)">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes008,('%var','%file'),($prmVarName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="filteredVars" as="element()+">
            <xsl:call-template name="filterElements">
                <xsl:with-param name="prmTargetElem" select="$vars"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="string($filteredVars[last()])"/>
        <xsl:if test="count($vars) gt 1">
            <!--xsl:message select="'$vars=',$vars"/-->
        </xsl:if>
    </xsl:template>

    <!-- 
         getVarValueAsText template
         function: Get variable value specified by $prmVarName, $prmXmlLang, $prmDocType, $prmPaperSize as text()
         parameter: prmVarName：Variable name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:template name="getVarValueAsText" as="text()">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="varValue" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$varValue"/>
    </xsl:template>

    <!-- 
         getVarValueWithLangAsText template
         function: Get variable as text() specified by $prmVarName considering $prmElem/@xml:lang as key.
         parameter: prmVarName: An variable name
                    prmElem: The relevant element
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:template name="getVarValueWithLangAsText" as="text()">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="curXmlLang" as="xs:string" select="ahf:getCurrentXmlLang($prmElem)"/>
        <xsl:variable name="varValue" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$varValue"/>
    </xsl:template>

    <!-- 
         getVarValueAsDouble template
         function: Get variable value specified by $prmVarName, $prmXmlLang, $prmDocType, $prmPaperSize as xs:double
         parameter: prmVarName：Variable name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:template name="getVarValueAsDouble" as="xs:double">
        <xsl:param name="prmVarName" as="xs:string"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="varValue" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$varValue castable as xs:double">
                <xsl:sequence select="xs:double($varValue)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes010,('%var','%value','%file'),($prmVarName,$varValue,$allStyleDefFile))"/>
                </xsl:call-template>
                <xsl:sequence select="xs:double(0)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getVarValueWithLangAsDouble" as="xs:double">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="curXmlLang" as="xs:string" select="ahf:getCurrentXmlLang($prmElem)"/>
        <xsl:variable name="varValueAsDouble" as="xs:double">
            <xsl:call-template name="getVarValueAsDouble">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$varValueAsDouble"/>
    </xsl:template>
    

    <!-- 
         getVarValueAsInteger template
         function: Get variable value specified by $prmVarName, $prmXmlLang, $prmDocType, $prmPaperSize as xs:integer
         parameter: prmVarName：Variable name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:function name="ahf:getVarValueAsInteger" as="xs:integer">
        <xsl:param name="prmVarName" as="xs:string"/>
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="$prmVarName"/>
            <xsl:with-param name="prmXmlLang" select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType" select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize" select="$defaultPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$defaultOutputType"/>
        </xsl:call-template>
    </xsl:function>

    <xsl:template name="getVarValueAsInteger" as="xs:integer">
        <xsl:param name="prmVarName" as="xs:string"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="varValue" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$varValue castable as xs:integer">
                <xsl:sequence select="xs:integer($varValue)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes012,('%var','%value','%file'),($prmVarName,$varValue,$allStyleDefFile))"/>
                </xsl:call-template>
                <xsl:sequence select="xs:integer(0)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
         getVarValueAsStringSequence template
         function: Get variable value specified by $prmVarName, $prmXmlLang, $prmDocType, $prmPaperSize as xs:string*
         parameter: prmVarName：Variable name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
                    prmDelim: Delimiter character
         note: 
    -->
    <xsl:function name="ahf:getVarValueAsStringSequence" as="xs:string*">
        <xsl:param name="prmVarName" as="xs:string"/>
        
        <xsl:call-template name="getVarValueAsStringSequence">
            <xsl:with-param name="prmVarName" select="$prmVarName"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:template name="getVarValueWithLangAsStringSequence" as="xs:string*">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="curXmlLang" as="xs:string" select="ahf:getCurrentXmlLang($prmElem)"/>
        <xsl:call-template name="getVarValueAsStringSequence">
            <xsl:with-param name="prmVarName" select="$prmVarName"/>
            <xsl:with-param name="prmXmlLang" select="$curXmlLang"/>
            <xsl:with-param name="prmDocType" select="$prmDocType"/>
            <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getVarValueAsStringSequence" as="xs:string*">
        <xsl:param name="prmVarName" required="yes" as="xs:string"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmDelim" as="xs:string" required="no" select="','"/>

        <xsl:variable name="stringAndDelim" as="xs:string+">
            <xsl:call-template name="getVarValueWithDelim">
                <xsl:with-param name="prmVarName" select="$prmVarName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="stringValue" as="xs:string" select="$stringAndDelim[1]"/>
        <xsl:variable name="delim" as="xs:string" select="$stringAndDelim[2]"/>
        <xsl:variable name="tempDelim" as="xs:string" select="$prmDelim"/>
        <xsl:for-each select="tokenize($stringValue,$delim)">
            <xsl:variable name="token" as="xs:string" select="."/>
            <xsl:choose>
                <xsl:when test="not(string($token))"/>
                <xsl:otherwise>
                    <xsl:sequence select="$token"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>    

    <xsl:template name="getVarValueWithDelim" as="xs:string+">
        <xsl:param name="prmVarName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="vars" as="element()*" select="$glVarDefs/*[string(@name) eq $prmVarName]"/>
        <xsl:if test="empty($vars)">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes008,('%var','%file'),($prmVarName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="filteredVars" as="element()+">
            <xsl:call-template name="filterElements">
                <xsl:with-param name="prmTargetElem" select="$vars"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="string($filteredVars[last()])"/>
        <xsl:sequence select="string($filteredVars[last()]/@delim)"/>
    </xsl:template>

    <!-- 
         getInstreamObject tempalte
         function: Get instream object specified by $prmObjName as node()*.
         parameter: prmObjName: Object name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:function name="ahf:getInstreamObject" as="node()*">
        <xsl:param name="prmObjName" as="xs:string"/>
        <xsl:call-template name="getInstreamObject">
            <xsl:with-param name="prmObjName" select="$prmObjName"/>
            <xsl:with-param name="prmXmlLang"  select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType"  select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize"  select="$defaultPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$defaultOutputType"/>
        </xsl:call-template>        
    </xsl:function>

    <xsl:template name="getInstreamObject" as="node()*">
        <xsl:param name="prmObjName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="objects" as="element()*" select="$glInstreamObjects/*[string(@name) eq $prmObjName]"/>
        <xsl:if test="empty($objects)">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes009,('%objname','%file'),($prmObjName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="filteredObjects" as="element()+">
            <xsl:call-template name="filterElements">
                <xsl:with-param name="prmTargetElem" select="$objects"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$filteredObjects[last()]/*[1]"/>
    </xsl:template>

    <!-- 
         getInstreamObjectReplacing template
         function: Get instream object specified by $prmObjName as node()* 
                   replacing text node from $prmSrcString by $prmDstString.
         parameter: prmObjName: Object name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
                    prmSrcStr: Source string
                    prmDstStr: Destination string
         note: 
      -->
    <xsl:function name="ahf:getInstreamObjectReplacing" as="node()*">
        <xsl:param name="prmObjName" as="xs:string"/>
        <xsl:param name="prmSrcStr" as="xs:string+"/>
        <xsl:param name="prmDstStr" as="xs:string+"/>
        
        <xsl:call-template name="getInstreamObjectReplacing">
            <xsl:with-param name="prmObjName" as="xs:string" select="$prmObjName"/>
            <xsl:with-param name="prmXmlLang" as="xs:string?" select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType" as="xs:string?" select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize" as="xs:string?" select="$defaultPaperSize"/>
            <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
            <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
        </xsl:call-template> 
    </xsl:function>

    <xsl:template name="getInstreamObjectReplacing" as="node()*">
        <xsl:param name="prmObjName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>

        <xsl:variable name="instreamObject" as="node()*">
            <xsl:call-template name="getInstreamObject">
                <xsl:with-param name="prmObjName" select="$prmObjName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="replacedInstreamObject" as="node()*">
            <xsl:apply-templates select="$instreamObject" mode="GET_INSTREAM_OBJECTS_REPLACING">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="$replacedInstreamObject"/>
    </xsl:template>
    
    <xsl:template match="svg:*|mml:*" mode="GET_INSTREAM_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="GET_INSTREAM_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="GET_INSTREAM_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:variable name="text" as="xs:string" select="."/>
        <xsl:choose>
            <xsl:when test="ahf:containsAnyOf($text,$prmSrcStr)">
                <!--xsl:message select="'[text()] ',$text,' contains ',$prmSrcStr"/>
                <xsl:message select="'$prmSrcStr= ',$prmSrcStr"/>
                <xsl:message select="'$prmDstStr= ',$prmDstStr"/>
                <xsl:message select="'ahf:replace($text,$prmSrcStr,$prmDstStr)= ',ahf:replace($text,$prmSrcStr,$prmDstStr)"/-->
                <xsl:value-of select="ahf:replace($text,$prmSrcStr,$prmDstStr)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*" mode="GET_INSTREAM_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:variable name="attr" as="xs:string" select="string(.)"/>
        <xsl:choose>
            <xsl:when test="ahf:containsAnyOf($attr,$prmSrcStr)">
                <xsl:attribute name="{name(.)}" select="ahf:replace($attr,$prmSrcStr,$prmDstStr)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="$attr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
         getFormattingObject tempalte
         function: Get XSL-FO object specified by $prmObjName as node()*.
         parameter: prmObjName: Object name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:function name="ahf:getFormattingObject" as="node()*">
        <xsl:param name="prmObjName" as="xs:string"/>
        <xsl:call-template name="getFormattingObject">
            <xsl:with-param name="prmObjName" select="$prmObjName"/>
            <xsl:with-param name="prmXmlLang"  select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType"  select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize"  select="$defaultPaperSize"/>
            <xsl:with-param name="prmOutputType" select="$defaultOutputType"/>
        </xsl:call-template>        
    </xsl:function>
    
    <xsl:template name="getFormattingObject" as="node()*">
        <xsl:param name="prmObjName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <xsl:variable name="objects" as="element()*" select="$glFormattingObjects/*[string(@name) eq $prmObjName]"/>
        <xsl:if test="empty($objects)">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes">
                    <xsl:value-of select="ahf:replace($stMes010,('%objname','%file'),($prmObjName,$allStyleDefFile))"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="filteredObjects" as="element()+">
            <xsl:call-template name="filterElements">
                <xsl:with-param name="prmTargetElem" select="$objects"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$filteredObjects[last()]/node()"/>
    </xsl:template>

    <!-- 
         getFormattingObjectReplacing template
         function: Get formatting object specified by $prmObjName as node()* 
                   replacing text node from $prmSrcString by $prmDstString.
         parameter: prmObjName: Object name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
                    prmSrcStr: Source string
                    prmDstStr: Destination string
         note: 
      -->
    <xsl:function name="ahf:getFormattingObjectReplacing" as="node()*">
        <xsl:param name="prmObjName" as="xs:string"/>
        <xsl:param name="prmSrcStr" as="xs:string+"/>
        <xsl:param name="prmDstStr" as="xs:string+"/>
        
        <xsl:call-template name="getFormattingObjectReplacing">
            <xsl:with-param name="prmObjName" as="xs:string" select="$prmObjName"/>
            <xsl:with-param name="prmXmlLang" as="xs:string?" select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType" as="xs:string?" select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize" as="xs:string?" select="$defaultPaperSize"/>
            <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
            <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
        </xsl:call-template> 
    </xsl:function>
    
    <xsl:template name="getFormattingObjectReplacing" as="node()*">
        <xsl:param name="prmObjName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        
        <xsl:variable name="formattingObject" as="node()*">
            <xsl:call-template name="getFormattingObject">
                <xsl:with-param name="prmObjName" select="$prmObjName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="replacedFormattingObject" as="node()*">
            <xsl:apply-templates select="$formattingObject" mode="GET_FORMATTING_OBJECTS_REPLACING">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="$replacedFormattingObject"/>
    </xsl:template>
    
    <xsl:template match="fo:*" mode="GET_FORMATTING_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="GET_FORMATTING_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstStr" select="$prmDstStr"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="GET_FORMATTING_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:variable name="text" as="xs:string" select="."/>
        <xsl:choose>
            <xsl:when test="ahf:containsAnyOf($text,$prmSrcStr)">
                <xsl:value-of select="ahf:replace($text,$prmSrcStr,$prmDstStr)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*" mode="GET_FORMATTING_OBJECTS_REPLACING">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstStr" as="xs:string+" required="yes"/>
        <xsl:variable name="attr" as="xs:string" select="string(.)"/>
        <xsl:choose>
            <xsl:when test="ahf:containsAnyOf($attr,$prmSrcStr)">
                <xsl:attribute name="{name(.)}" select="ahf:replace($attr,$prmSrcStr,$prmDstStr)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="$attr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
         getFormattingObjectReplacingNode template
         function: Get formatting object specified by $prmObjName as node()* 
                   replacing text node from $prmSrcString by $prmDstNode.
         parameter: prmObjName: Object name
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
                    prmSrcStr: Source string
                    prmDstNode: Destination node stored under the each element
         note: 
      -->
    <xsl:function name="ahf:getFormattingObjectReplacingNode" as="node()*">
        <xsl:param name="prmObjName" as="xs:string"/>
        <xsl:param name="prmSrcStr" as="xs:string+"/>
        <xsl:param name="prmDstNode" as="element()+"/>
        
        <xsl:call-template name="getFormattingObjectReplacingNode">
            <xsl:with-param name="prmObjName" as="xs:string" select="$prmObjName"/>
            <xsl:with-param name="prmXmlLang" as="xs:string?" select="$defaultXmlLang"/>
            <xsl:with-param name="prmDocType" as="xs:string?" select="$defaultDocType"/>
            <xsl:with-param name="prmPaperSize" as="xs:string?" select="$defaultPaperSize"/>
            <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
            <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
        </xsl:call-template> 
    </xsl:function>
    
    <xsl:template name="getFormattingObjectReplacingNode" as="node()*">
        <xsl:param name="prmObjName" as="xs:string" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstNode" as="element()+" required="yes"/>
        
        <xsl:variable name="formattingObject" as="node()*">
            <xsl:call-template name="getFormattingObject">
                <xsl:with-param name="prmObjName" select="$prmObjName"/>
                <xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
                <xsl:with-param name="prmDocType" select="$prmDocType"/>
                <xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
                <xsl:with-param name="prmOutputType" select="$prmOutputType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="replacedFormattingObject" as="node()*">
            <xsl:apply-templates select="$formattingObject" mode="GET_FORMATTING_OBJECTS_REPLACING_NODE">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="$replacedFormattingObject"/>
    </xsl:template>
    
    <xsl:template match="fo:*" mode="GET_FORMATTING_OBJECTS_REPLACING_NODE">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstNode" as="element()+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="GET_FORMATTING_OBJECTS_REPLACING_NODE">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstNode" as="element()+" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="prmSrcStr" select="$prmSrcStr"/>
                <xsl:with-param name="prmDstNode" select="$prmDstNode"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="GET_FORMATTING_OBJECTS_REPLACING_NODE">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstNode" as="element()+" required="yes"/>
        <xsl:variable name="text" as="xs:string" select="."/>
        <xsl:variable name="index" as="xs:integer?" select="index-of($prmSrcStr,$text)[1]"/>
        <xsl:choose>
            <xsl:when test="exists($index)">
                <xsl:copy-of select="$prmDstNode[$index]/node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*" mode="GET_FORMATTING_OBJECTS_REPLACING_NODE">
        <xsl:param name="prmSrcStr" as="xs:string+" required="yes"/>
        <xsl:param name="prmDstNode" as="element()+" required="yes"/>
        <xsl:variable name="attr" as="xs:string" select="string(.)"/>
        <xsl:variable name="index" as="xs:integer?" select="index-of($prmSrcStr,$attr)[1]"/>
        <xsl:choose>
            <xsl:when test="exists($index)">
                <xsl:attribute name="{name(.)}" select="string($prmDstNode[$index])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="$attr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!-- 
         filterElements template
         function： Apply filtering to the element specified by $prmTargetElem using parameter $prmXmlLang,$prmDocType,$prmPaperSize.
         parameter: prmTargetElems：Target element（attribute-set,variable,etc)
                    prmXmlLang: Target xml:lang
                    prmDocType: Document type
                    prmPaperSize: Paper size
         note: 
      -->
    <xsl:template name="filterElements" as="element()*">
        <xsl:param name="prmTargetElem" as="element()*" required="yes"/>
        <xsl:param name="prmXmlLang" as="xs:string?" required="no" select="$defaultXmlLang"/>
        <xsl:param name="prmDocType" as="xs:string?" required="no" select="$defaultDocType"/>
        <xsl:param name="prmPaperSize" as="xs:string?" required="no" select="$defaultPaperSize"/>
        <xsl:param name="prmOutputType" as="xs:string?" required="no" select="$defaultOutputType"/>
        
        <!-- Get variable value from tight condition. 
             If there is N'th conditions, there are 2**N th patterns are needed.
         -->
        <xsl:choose>
            <!-- Matches xml:lang, doc-type, paper-size and output-type (4) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang, doc-type and paper-size (3) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang, doc-type and output-type (3) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [empty(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [empty(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang, paper-size and output-type (3) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [empty(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [empty(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches doc-type, paper-size and output-type (3) -->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang and doc-type (2) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [empty(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [empty(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang and paper-size (2) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [empty(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [empty(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang and output-type (2) -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [empty(@doc-type)]
                [empty(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [empty(@doc-type)]
                    [empty(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches doc-type and paper-size (2)-->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches doc-type and output-type (2)-->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [empty(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [empty(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches paper-size and output-type (2)-->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [empty(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [empty(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches doc-type -->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                [exists(@doc-type)]
                [empty(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
                    [exists(@doc-type)]
                    [empty(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches paper-size -->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [empty(@doc-type)]
                [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                [exists(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [empty(@doc-type)]
                    [ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
                    [exists(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches output-type -->
            <xsl:when test="$prmTargetElem[empty(@xml:lang)]
                [empty(@doc-type)]
                [empty(@paper-size)]
                [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                [exists(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[empty(@xml:lang)]
                    [empty(@doc-type)]
                    [empty(@paper-size)]
                    [ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
                    [exists(@output-type)]
                    "/>
            </xsl:when>
            <!-- Matches xml:lang -->
            <xsl:when test="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                [exists(@xml:lang)]
                [empty(@doc-type)]
                [empty(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
                    [exists(@xml:lang)]
                    [empty(@doc-type)]
                    [empty(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- reference to language neutral resource -->
            <xsl:when test="$prmTargetElem
                [empty(@xml:lang)]
                [empty(@doc-type)]
                [empty(@paper-size)]
                [empty(@output-type)]
                ">
                <xsl:sequence select="$prmTargetElem
                    [empty(@xml:lang)]
                    [empty(@doc-type)]
                    [empty(@paper-size)]
                    [empty(@output-type)]
                    "/>
            </xsl:when>
            <!-- matches only variable name -->
            <xsl:otherwise>
                <xsl:sequence select="$prmTargetElem"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- end of stylesheet -->
</xsl:stylesheet>
