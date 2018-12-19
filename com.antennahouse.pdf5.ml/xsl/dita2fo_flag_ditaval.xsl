<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: .ditaval flag processing templates
Copyright © 2009-2019 Antenna House, Inc. All rights reserved.
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
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs ahf dita-ot"
>
    <!-- This template handles the result of DITAVAL file flagging.
         The result of flagging is constructed by DITA-OT as follows:
         
         [.ditaval]
            <prop action="flag" att="audience" val="general" backcolor="#f1f1f1" color="#ff0000" style="italics">
                <startflag imageref="start.png">
                    <alt-text>START</alt-text>
                </startflag>
                <endflag imageref="end.png">
                    <alt-text>END</alt-text>
                </endflag>
            </prop>
            <revprop action="flag" val="deltaxml-add" backcolor="#e0ffe0" style="underline" changebar="style:solid;width:3pt;offset:5pt;color:blue">
                <startflag imageref="start.png">
                    <alt-text>START</alt-text>
                </startflag>
                <endflag imageref="end.png">
                    <alt-text>END</alt-text>
                </endflag>
            </revprop>
         
         [Original authoring]
            <p  audience="general" rev="deltaxml-add">This paragraph has rev="deltaxml-add" &amp; audience="general" attribute.</p>
         
         [Merged middle file: Added indentation]
            <p audience="general" class="- topic/p " rev="deltaxml-add" xtrc="p:1;16:51"
                xtrf="file:/C:/Users/toshi/OneDrive/Documents/test/dita/20181217-revprop/cRevpropTest.dita">
                <ditaval-startprop class="+ topic/foreign ditaot-d/ditaval-startprop " outputclass="color:#ff0000;background-color:#f1f1f1;font-style:italic;">
                    <prop action="flag" backcolor="#f1f1f1" color="#ff0000" style="italics">
                        <startflag action="flag" dita-ot:imagerefuri="start.png"
                            dita-ot:original-imageref="start.png" imageref="start.png">
                            <alt-text>START</alt-text>
                        </startflag>
                    </prop>
                </ditaval-startprop>
                <ditaval-startprop class="+ topic/foreign ditaot-d/ditaval-startprop " outputclass="background-color:#e0ffe0;text-decoration:underline;">
                    <revprop action="flag" backcolor="#e0ffe0" changebar="style:solid;width:3pt;offset:5pt;color:blue" style="underline">
                        <startflag action="flag" dita-ot:imagerefuri="start.png" dita-ot:original-imageref="start.png" imageref="start.png">
                            <alt-text>START</alt-text>
                        </startflag>
                    </revprop>
                </ditaval-startprop>
                This paragraph has rev="deltaxml-add" &amp; audience="general" attribute.
                <ditaval-endprop class="+ topic/foreign ditaot-d/ditaval-endprop ">
                    <prop action="flag" backcolor="#f1f1f1" color="#ff0000" style="italics">
                        <endflag action="flag" dita-ot:imagerefuri="end.png" dita-ot:original-imageref="end.png" imageref="end.png">
                            <alt-text>END</alt-text>
                        </endflag>
                    </prop>
                </ditaval-endprop>
                <ditaval-endprop class="+ topic/foreign ditaot-d/ditaval-endprop ">
                    <revprop action="flag" backcolor="#e0ffe0" changebar="style:solid;width:3pt;offset:5pt;color:blue" style="underline">
                        <endflag action="flag" dita-ot:imagerefuri="end.png" dita-ot:original-imageref="end.png" imageref="end.png">
                            <alt-text>END</alt-text>
                        </endflag>
                    </revprop>
                </ditaval-endprop>
            </p>
         
         The requirement of for flagging is described as:
         
         2.4.3.3 Flagging
         http://docs.oasis-open.org/dita/dita/v1.3/errata02/os/complete/part3-all-inclusive/archSpec/base/flagging.html#flagging
         
         "When deciding whether to flag a particular element, a processor should evaluate each value. Wherever an
         attribute value that has been set as flagged appears (for example, audience="administrator"), the
         processor should add the flag. When multiple flags apply to a single element, multiple flags should be rendered,
         typically in the order that they are encountered."
    -->

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
    
    <xsl:attribute-set name="atsAlt">
        <xsl:attribute name="class" select="' topic/alt '"/>
        <xsl:attribute name="xtrf" select="'.ditaval'"/>
        <xsl:attribute name="xtrc" select="''"/>
    </xsl:attribute-set>

    <xsl:attribute-set name="atsP">
        <xsl:attribute name="class" select="' topic/p '"/>
        <xsl:attribute name="xtrf" select="'.ditaval'"/>
        <xsl:attribute name="xtrc" select="''"/>
    </xsl:attribute-set>

    <!-- 
     function:	Template for block-level elements that has ditaval-startprop,endprop element as its child.
     param:		none
     return:	generate outer block image and call next matching template
     note:		tgroup is not supported!
     -->
    <xsl:template match="*[ahf:isListElement(.) or contains(@class,' topic/table ') or contains(@class,' topic/simpletable ')]
                          [ahf:hasDitaValStartPropWithImageFlag(.) or ahf:hasDitaValEndPropWithImageFlag(.)]" 
                  priority="20">
        <xsl:for-each select="ahf:getStartFlagWithImage(.)">
            <xsl:call-template name="genBlocLevelImageOrTextForFlagging">
                <xsl:with-param name="prmFlagElem" select="."/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:next-match/>
        <xsl:for-each select="ahf:getEndFlagWithImage(.)">
            <xsl:call-template name="genBlocLevelImageOrTextForFlagging">
                <xsl:with-param name="prmFlagElem" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	Generate block level flag image or text 
     param:		prmFlagElem (startflag or endflag)
     return:	generated image or p elements
     note:		
     -->
    <xsl:template name="genBlocLevelImageOrTextForFlagging" as="element()?">
        <xsl:param name="prmFlagElem" as="element()" required="yes"/>
        <xsl:choose>
            <xsl:when test="exists($prmFlagElem/@dita-ot:imagerefuri)">
                <image use-attribute-sets="atsFlagBlockImage">
                    <xsl:attribute name="href" select="string($prmFlagElem/@dita-ot:imagerefuri)"/>
                    <xsl:if test="$prmFlagElem/alt">
                        <alt xsl:use-attribute-sets="atsAlt">
                            <xsl:copy-of select="$prmFlagElem/alt/node()"/>
                        </alt>
                    </xsl:if>
                </image>
            </xsl:when>
            <xsl:when test="string(normalize-space(string($prmFlagElem/alt)))">
                <p use-attribute-sets="atsP">
                    <xsl:copy-of select="$prmFlagElem/alt/node()"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Template for image, xref elements that has ditaval-startprop,endprop element as its child.
     param:		none
     return:	generate outer block image and call next matching template
     note:		If the schema specialization has empty inline elements, you should append its class here! 
     -->
    <xsl:template match="*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]
        [ahf:hasDitaValStartPropWithImageFlag(.) or ahf:hasDitaValEndPropWithImageFlag(.)]" 
        priority="20">
        <xsl:if test="ahf:hasDitaValStartPropWithImageFlag(.)">
            <image  xsl:use-attribute-sets="atsFlagInlineImage">
                <xsl:attribute name="href" select="ahf:getFirstChildStartFlagImageRef(.)"/>
            </image>
        </xsl:if>
        <xsl:next-match/>
        <xsl:if test="ahf:hasDitaValEndPropWithImageFlag(.)">
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
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[ahf:isTableRelatedElement(.)]]" priority="20"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[ahf:isTableRelatedElement(.)]]" priority="20"/>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[ahf:isListElement(.)]]" priority="20"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[ahf:isListElement(.)]]" priority="20"/>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][parent::*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]]" priority="20"/>
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][parent::*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]]" priority="20"/>
    
    <!-- 
     function:	Template for ditaval-startprop, endprop element that has effective prop/startflag/@imageref or prop/endflag/@imageref 
     param:		none
     return:	generate inline image
     note:		This template is intended to apply inline level elements.
     -->
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')][ahf:hasDitaValWithImageStartFlag(.)]" priority="10">
        <image  xsl:use-attribute-sets="atsFlagInlineImage">
            <xsl:attribute name="href" select="ahf:getDitaValImageStartFlag(.)"/>
        </image>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')][ahf:hasDitaValWithImageEndFlag(.)]" priority="10">
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
    <xsl:template match="*[ahf:hasFirstChildDitaValStartProp(.)]" priority="5">
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
     function:	Check ditaval-startprop/prop or revprop/startflag/@imageref or alt-text and 
                      ditaval-endprop/prop or revprop/endflag/@imageref or alt-text 
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasDitaValWithImageStartFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="some $startflag in $prmElem/*[self::prop or self::revprop]/startflag satisfies (exists($startflag/@imageref) or string(normalize-space(string($startflag/alt-text))))"/>
    </xsl:function>
    
    <xsl:function name="ahf:hasDitaValWithImageEndFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="some $endflag in $prmElem/*[self::prop or self::revprop]/endflag satisfies (exists($endflag/@imageref) or string(normalize-space(string($endflag/alt-text))))"/>
    </xsl:function>

    <!-- 
     function:	Get ditaval-startprop/prop or revprop/startflag and 
                    ditaval-endprop/prop or revprop/endflag 
     param:		prmElem
     return:	element()*
     note:		
     -->
    <xsl:function name="ahf:getStartFlagWithImage" as="element()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[self::prop or self::revprop]/startflag"/>
    </xsl:function>
    
    <xsl:function name="ahf:getEndFlagWithImage" as="element()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[self::prop or self::revprop]/endflag"/>
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
     function:	Check child ditaval-startprop element that has prop/startflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasDitaValStartPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/child::*[contains(@class, ' ditaot-d/ditaval-startprop ')][ahf:hasDitaValWithImageStartFlag(.)])"/>
    </xsl:function>

    <!-- 
     function:	Check child ditaval-endprop element that has prop/endflag/@imageref
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasDitaValEndPropWithImageFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/child::*[contains(@class, ' ditaot-d/ditaval-endprop ')][ahf:hasDitaValWithImageEndFlag(.)])"/>
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
