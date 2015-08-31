<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: .ditaval flag processing templates
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
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
>

    <!-- attributes for auto generate image -->
    <xsl:attribute-set name="atsFlagInlineImage">
        <xsl:attribute name="class" select="' topic/image '"/>
        <xsl:attribute name="placement" select="'inline'"/>
        <xsl:attribute name="scope" select="'external'"/>
        <xsl:attribute name="xtrf" select="'.ditaval'"/>
        <xsl:attribute name="xtrc" select="''"/>
    </xsl:attribute-set>

    <xsl:attribute-set name="atsFlagBlockImage" use-attribute-sets="atsFlagInlineImage">
        <xsl:attribute name="placement" select="'break'"/>
    </xsl:attribute-set>

    <!-- 
     function:	Template for block-level elements that has ditaval-startprop,endprop element as its child.
     param:		none
     return:	generate outer block image and call next matching template
     note:		tgroup is not supported!
     -->
    <xsl:template match="*[ahf:isListElement(.) or contains(@class,' topic/table ') or contains(@class,' topic/simpletable ')]
                          [ahf:hasFirstChildDitaValStartPropWithImageFlag(.) or ahf:hasLastChildDitaValEndPropWithImageFlag(.)]" 
                  priority="6">
        <xsl:if test="ahf:hasFirstChildDitaValStartPropWithImageFlag(.)">
            <image  xsl:use-attribute-sets="atsFlagBlockImage">
                <xsl:attribute name="href" select="ahf:getFirstChildStartFlagImageRef(.)"/>
            </image>
        </xsl:if>
        <xsl:next-match/>
        <xsl:if test="ahf:hasLastChildDitaValEndPropWithImageFlag(.)">
            <image  xsl:use-attribute-sets="atsFlagBlockImage">
                <xsl:attribute name="href" select="ahf:getLastChildEndFlagImageRef(.)"/>
            </image>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	Template for image, xref elements that has ditaval-startprop,endprop element as its child.
     param:		none
     return:	generate outer block image and call next matching template
     note:		If the schema specialization has empty inline elements, you should append its class here! 
     -->
    <xsl:template match="*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]
        [ahf:hasFirstChildDitaValStartPropWithImageFlag(.) or ahf:hasLastChildDitaValEndPropWithImageFlag(.)]" 
        priority="6">
        <xsl:if test="ahf:hasFirstChildDitaValStartPropWithImageFlag(.)">
            <image  xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getFirstChildStartFlagImageRef(.)"/>
            </image>
        </xsl:if>
        <xsl:next-match/>
        <xsl:if test="ahf:hasLastChildDitaValEndPropWithImageFlag(.)">
            <image  xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getLastChildEndFlagImageRef(.)"/>
            </image>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	Template for ditaval-startprop,endprop element that is for the table, list, image, xref element
     param:		none
     return:	ignore
     note:		
     -->
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[ahf:isTableRelatedElement(.)]]" priority="6"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[ahf:isTableRelatedElement(.)]]" priority="6"/>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[ahf:isListElement(.)]]" priority="6"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[ahf:isListElement(.)]]" priority="6"/>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]]" priority="6"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]]" priority="6"/>
    
    <!-- 
     function:	Template for ditaval-startprop, endprop element that has effective prop/startflag/@imageref or prop/endflag/@imageref 
     param:		none
     return:	generate inline image
     note:		This template is intended to apply inline level elements.
     -->
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][ahf:hasDitaValWithImageStartFlag(.)]" priority="4">
        <image  xsl:use-attribute-sets="atsFlagInlineImage">
            <xsl:attribute name="href" select="ahf:getDitaValImageStartFlag(.)"/>
        </image>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][ahf:hasDitaValWithImageEndFlag(.)]" priority="4">
        <image  xsl:use-attribute-sets="atsFlagInlineImage">
            <xsl:attribute name="href" select="ahf:getDitaValImageEndFlag(.)"/>
        </image>
    </xsl:template>

    <!-- 
     function:	Check table and descendant element
     param:		prmElem
     return:	xs:boolean
     note:		If $prmElem is table or it's descendant element, return true.
     -->
    <xsl:variable name="cTableRelatedClass" as="xs:string+" select="(' topic/table ',' topic/tgroup ',' topic/thead ',' topic/tbody ',' topic/row ')"/>
    <xsl:variable name="cSimpleTableRelatedClass" as="xs:string+" select="(' topic/simpletable ',' topic/sthead ',' topic/strow ')"/>
    
    <xsl:function name="ahf:isTableRelatedElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:seqContains(string($prmElem/@class),($cTableRelatedClass,$cSimpleTableRelatedClass))"/>
    </xsl:function>
    
    <!-- 
     function:	Check list element
     param:		prmElem
     return:	xs:boolean
     note:		If $prmElem is ol, ul, sl, dl return true.
     -->
    <xsl:variable name="cListClass" as="xs:string+" select="(' topic/ol ',' topic/ul ',' topic/sl ',' topic/dl ')"/>
    
    <xsl:function name="ahf:isListElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:seqContains(string($prmElem/@class),$cListClass)"/>
    </xsl:function>

    <!-- 
     function:	Template for element that has effective ditaval-startprop element as first child
     param:		none
     return:	copied result
     note:		This template generates style from .ditaval prop/action="flag" element's style.
                This style is passed as $prmDitaValFlagStyle tunnel parameter.
     -->
    <xsl:template match="*[ahf:hasFirstChildDitaValStartProp(.)]" priority="2">
        <xsl:variable name="ditaValProp" as="element()" select="ahf:getFirstChildDitavalProp(.)"/>
        <xsl:variable name="ditaValFlagStyle" as="xs:string" select="ahf:getDitaValFlagStyle($ditaValProp)"/>
        <xsl:next-match>
            <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="$ditaValFlagStyle"/>
        </xsl:next-match>
    </xsl:template>

    <!-- 
     function:	Check first child is effective ditava-startprop element
     param:		prmElem
     return:	xs:boolean
     note:		If $prmElem has first child ditaval-startprop element, return true.
     -->
    <xsl:function name="ahf:hasFirstChildDitaValStartProp" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/*[1][contains(@class, ' ditaot-d/ditaval-startprop ')]/prop[exists(@backcolor|@color|@style)])"/>
    </xsl:function>
    
    <!-- 
     function:	Get first child ditava-startprop/prop element
     param:		prmElem
     return:	element()
     note:		Return first child ditaval-startprop/prop element.
     -->
    <xsl:function name="ahf:getFirstChildDitavalProp" as="element()">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[1][contains(@class, ' ditaot-d/ditaval-startprop ')]/prop[1]"/>
    </xsl:function>
    
    <!-- 
     function:	Merge ditaval/prop flag attributes with $prmElem/fo:prop attribute
     param:		prmElem, prmDitaValProp
     return:	xs:string
     note:		Falgging style is stored in prmDitaValStartProp/prop/@color,@backcolor,@style.
     -->
    <xsl:function name="ahf:mergeDitaValFlagStyle" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmDitaValFlagStyle" as="xs:string"/>
        <xsl:variable name="fo:prop" as="xs:string" select="string($prmElem/@fo:prop)"/>
        <xsl:choose>
            <xsl:when test="string($fo:prop)">
                <xsl:sequence select="concat($fo:prop,if (ends-with($fo:prop,';')) then '' else ';',$prmDitaValFlagStyle)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$prmDitaValFlagStyle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Generate CSS style notation from ditaval-startprop/prop/@color,@backcolor,@style attribute
     param:		prmDitaValProp
     return:	xs:string
     note:		
     -->
    <xsl:function name="ahf:getDitaValFlagStyle" as="xs:string">
        <xsl:param name="prmDitaValProp" as="element()"/>
        <xsl:variable name="color" as="xs:string">
            <xsl:variable name="colorVal" as="xs:string" select="normalize-space(string($prmDitaValProp/@color))"/>
            <xsl:choose>
                <xsl:when test="string($colorVal)">
                    <xsl:sequence select="concat('color:',$colorVal,';')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="backColor" as="xs:string">
            <xsl:variable name="backColorVal" as="xs:string" select="normalize-space(string($prmDitaValProp/@backcolor))"/>
            <xsl:choose>
                <xsl:when test="string($backColorVal)">
                    <xsl:sequence select="concat('background-color:',$backColorVal,';')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="style" as="xs:string">
            <xsl:variable name="styleVal" as="xs:string" select="normalize-space(string($prmDitaValProp/@style))"/>
            <xsl:choose>
                <xsl:when test="$styleVal eq 'underline'">
                    <xsl:sequence select="concat('text-decoration:',$styleVal,';')"/>
                </xsl:when>
                <xsl:when test="$styleVal eq 'double-underline'">
                    <xsl:sequence select="concat('text-decoration:','underline',';','axf-text-line-style:','double',';')"/>
                </xsl:when>
                <xsl:when test="$styleVal eq 'italics'">
                    <xsl:sequence select="concat('font-style:','italic',';')"/>
                </xsl:when>
                <xsl:when test="$styleVal eq 'overline'">
                    <xsl:sequence select="concat('text-decoration:',$styleVal,';')"/>
                </xsl:when>
                <xsl:when test="$styleVal eq 'bold'">
                    <xsl:sequence select="concat('font-weight:',$styleVal,';')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="concat($color,$backColor,$style)"/>
    </xsl:function>

    <!-- 
     function:	Get concatinated fo:prop attribute with ditaval-startprop/@outputclass and $prmElem/fo:prop
     param:		prmElem, prmDitaValStartProp
     return:	attribute()
     note:		
     -->
    <xsl:function name="ahf:getMergedDitaValFlagStyleAttr" as="attribute()">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmDitaValStartProp" as="xs:string"/>
        <xsl:attribute name="fo:prop" select="ahf:mergeDitaValFlagStyle($prmElem,$prmDitaValStartProp)"/>
    </xsl:function>

    <!-- 
     function:	Template for entry element that has preceding-sibling ditaval-startprop element.(This means that parent row has image flag.)
     param:		none
     return:	copied result
     note:		Abondon supporting flagging for row because it conflicts with entry flagging.
     -->
    <!--xsl:template match="*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ')][ahf:hasPrecedingSiblingDitaValStartPropWithImageFlag(.)]" priority="2">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <image  xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getPrecedingSiblingDitaValStartPropImageRef(.)"/>
            </image>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template-->
    
    <!-- 
     function:	Check first precedind-sibling ditava-startprop element that have prop/startflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasPrecedingSiblingDitaValStartPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/preceding-sibling::*[1][contains(@class, ' ditaot-d/ditaval-startprop ')][ahf:hasDitaValWithImageStartFlag(.)])"/>
    </xsl:function>
    
    <!-- 
     function:	Get first precedind-sibling ditava-startprop/prop/startflag/@imageref
     param:		prmElem
     return:	xs:string
     note:		Return first child ditaval-startprop element.
     -->
    <xsl:function name="ahf:getPrecedingSiblingDitaValStartPropImageRef" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getDitaValImageStartFlag($prmElem/preceding-sibling::*[1][contains(@class, ' ditaot-d/ditaval-startprop ')])"/>
    </xsl:function>

    <!-- 
     function:	Check ditaval-startprop/prop/startflag,endflag/@imageref or ditaval-startprop/prop/endflag,endflag/@imageref 
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasDitaValWithImageStartFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/prop[1]/startflag[1]/@imageref)"/>
    </xsl:function>
    
    <xsl:function name="ahf:hasDitaValWithImageEndFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/prop[1]/endflag[1]/@imageref)"/>
    </xsl:function>

    <!-- 
     function:	Get ditava-startprop/prop/startflag/@imageref or ditava-startprop/prop/endflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:getDitaValImageStartFlag" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:replace(string($prmElem/prop[1]/startflag[1]/@imageref),'../file:/','file:/')"/>
    </xsl:function>

    <xsl:function name="ahf:getDitaValImageEndFlag" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:replace(string($prmElem/prop[1]/endflag[1]/@imageref),'../file:/','file:/')"/>
    </xsl:function>
    

    <!-- 
     function:	Template for entry element that has following-sibling ditaval-endprop element. (This means that parent row has image flag.)
     param:		none
     return:	copied result
     note:		Abondon supporting flagging for row because it conflicts with entry flagging.
     -->
    <!--xsl:template match="*[contains(@class, ' topic/entry ')][ahf:hasFollowingSiblingDitaValEndPropWithImageFlag(.)]" priority="2">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates/>
            <image xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getFollowingSiblingEndFlagImageRef(.)"/>
            </image>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ')][ahf:hasPrecedingSiblingDitaValStartPropWithImageFlag(.)][ahf:hasFollowingSiblingDitaValEndPropWithImageFlag(.)]" priority="4">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <image xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getPrecedingSiblingDitaValStartPropImageRef(.)"/>
            </image>
            <xsl:apply-templates/>
            <image xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getFollowingSiblingEndFlagImageRef(.)"/>
            </image>
        </xsl:copy>
    </xsl:template-->

    <!-- 
     function:	Check first following-sibling ditaval-endprop element that has prop/endflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasFollowingSiblingDitaValEndPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/following-sibling::*[1][contains(@class, ' ditaot-d/ditaval-endprop ')][ahf:hasDitaValWithImageEndFlag(.)])"/>
    </xsl:function>
    
    <!-- 
     function:	Get first following-sibling ditava-endprop/prop/endflag/@imageref
     param:		prmElem
     return:	xs:string
     note:		Return first child ditaval-startprop element.
     -->
    <xsl:function name="ahf:getFollowingSiblingEndFlagImageRef" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getDitaValImageEndFlag($prmElem/following-sibling::*[1][contains(@class, ' ditaot-d/ditaval-endprop ')])"/>
    </xsl:function>

    <!-- 
     function:	Check first child ditaval-startprop element that has prop/startflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasFirstChildDitaValStartPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/child::*[1][contains(@class, ' ditaot-d/ditaval-startprop ')][ahf:hasDitaValWithImageStartFlag(.)])"/>
    </xsl:function>

    <!-- 
     function:	Check last child ditaval-endprop element that has prop/endflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasLastChildDitaValEndPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/child::*[last()][contains(@class, ' ditaot-d/ditaval-endprop ')][ahf:hasDitaValWithImageEndFlag(.)])"/>
    </xsl:function>
    
    <!-- 
     function:	Get first child ditaval-stratprop/prop/startflag/@imageref
     param:		prmElem
     return:	xs:string
     note:		Return first child ditaval-startprop element.
     -->
    <xsl:function name="ahf:getFirstChildStartFlagImageRef" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getDitaValImageStartFlag($prmElem/child::*[1][contains(@class, ' ditaot-d/ditaval-startprop ')])"/>
    </xsl:function>

    <!-- 
     function:	Get last child ditaval-endprop/prop/endflag/@imageref
     param:		prmElem
     return:	xs:string
     note:		Return first child ditaval-startprop element.
     -->
    <xsl:function name="ahf:getLastChildEndFlagImageRef" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getDitaValImageEndFlag($prmElem/child::*[last()][contains(@class, ' ditaot-d/ditaval-endprop ')])"/>
    </xsl:function>

</xsl:stylesheet>
