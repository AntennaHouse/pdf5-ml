<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Define DITA class related function
    Copyright © 2009-2019 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    
    <!-- DITA elements that generates inline level formattting objects
     -->
    <xsl:variable name="inlineElementClasses" as="xs:string+" select="
        (
        ' topic/boolean ',
        ' topic/cite ',
        ' topic/keyword ',
        ' topic/ph ',
        ' topic/q ',
        ' topic/term ',
        ' topic/text ',
        ' topic/tm ',
        ' topic/xref ',
        ' topic/state '
        )"/>

    <!-- 
     function:  Return $prmElem/@class has the value in $inlineElementClasses
     param:     $prmElem
     return:    xs:boolean
     note:      
     -->
    <xsl:function name="ahf:isInlineElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="class" as="xs:string" select="string($prmElem/@class)"/>
        <xsl:variable name="isOneOfInlineElement" as="xs:boolean" select="some $c in $inlineElementClasses satisfies contains($class,$c)"/>
        <xsl:variable name="isInlineImage" as="xs:boolean" select="contains($class,' topic/image ') and (string($prmElem/@placement) eq 'inline')"/>
        <xsl:sequence select="$isOneOfInlineElement or $isInlineImage"/>
    </xsl:function>

    <!-- Ignorable elements that is pointed from xref 
     -->
    <xsl:variable name="ignorebleElementClasses" as="xs:string+" select="
        (
        ' topic/draft-comment ',
        ' topic/required-cleanup ',
        ' topic/related-links ',
        ' topic/link ',
        ' topic/linktext ',
        ' topic/linklist ',
        ' topic/linkinfo ',
        ' topic/object ',
        ' topic/indexterm ',
        ' topic/index-base ',
        ' topic/data ',
        ' topic/data-about ',
        ' topic/foreign ',
        ' topic/unknown ',
        ' topic/fn ',
        ' topic/xref '
        )"/>
    
    <!-- 
     function:  Return $prmElem/@class has value in $ignorebleElementClasses
     param:     $prmElem
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isIgnorebleElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="class" as="xs:string" select="string($prmElem/@class)"/>
        <xsl:variable name="isOneOfIgnorebleElement" as="xs:boolean" select="some $c in $ignorebleElementClasses satisfies contains($class,$c)"/>
        <xsl:sequence select="$isOneOfIgnorebleElement"/>
    </xsl:function>

</xsl:stylesheet>
