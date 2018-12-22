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

    <!-- attributes for auto generate image or text -->
    <xsl:attribute-set name="atsFlagGlobal">
        <xsl:attribute name="xtrf" select="'.ditaval'"/>
        <xsl:attribute name="xtrc" select="''"/>
    </xsl:attribute-set>

    <xsl:attribute-set name="atsFlagInlineImage" use-attribute-sets="atsFlagGlobal">
        <xsl:attribute name="class" select="' topic/image '"/>
        <xsl:attribute name="placement" select="'inline'"/>
        <xsl:attribute name="scope" select="'external'"/>
    </xsl:attribute-set>

    <xsl:attribute-set name="atsFlagBlockImage" use-attribute-sets="atsFlagInlineImage">
        <xsl:attribute name="placement" select="'break'"/>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="atsAlt" use-attribute-sets="atsFlagGlobal">
        <xsl:attribute name="class" select="' topic/alt '"/>
    </xsl:attribute-set>

    <xsl:attribute-set name="atsP" use-attribute-sets="atsFlagGlobal">
        <xsl:attribute name="class" select="' topic/p '"/>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="atsPh" use-attribute-sets="atsFlagGlobal">
        <xsl:attribute name="class" select="' topic/ph '"/>
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
     note:		Treat image as relative to map if it does not begin with "https:/", "http:/", "ftp:/", "file:/".
     -->
    <xsl:template name="genBlocLevelImageOrTextForFlagging" as="element()?">
        <xsl:param name="prmFlagElem" as="element()" required="yes"/>
        <xsl:choose>
            <xsl:when test="exists($prmFlagElem/@dita-ot:imagerefuri)">
                <xsl:variable name="imageRefUri" as="xs:string" select="string($prmFlagElem/@dita-ot:imagerefuri)"/>
                <image use-attribute-sets="atsFlagBlockImage">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="ahf:isAbsUri($imageRefUri)">
                                <xsl:value-of select="$imageRefUri"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($pMapDirUrl,$imageRefUri)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="$prmFlagElem/alt-text">
                        <alt xsl:use-attribute-sets="atsAlt">
                            <xsl:copy-of select="$prmFlagElem/alt-text/node()"/>
                        </alt>
                    </xsl:if>
                </image>
            </xsl:when>
            <xsl:when test="string(normalize-space(string($prmFlagElem/alt-text)))">
                <p use-attribute-sets="atsP">
                    <xsl:copy-of select="$prmFlagElem/alt-text/node()"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Judge absolute URI
     param:		prmUri
     return:	xs:boolean
     note:		If $prm Uri starts with "http:/" or "https:/" or "file:/" return true 
     -->
    <xsl:function name="ahf:isAbsUri" as="xs:boolean">
        <xsl:param name="prmUri" as="xs:string"/>
        <xsl:sequence select="starts-with($prmUri,'http:/') or starts-with($prmUri,'https:/') or starts-with($prmUri,'file:/') or starts-with($prmUri,'ftp:/')"/>
    </xsl:function>

    <!-- 
     function:	Template for image, xref elements that has ditaval-startprop,endprop element as its child.
     param:		none
     return:	generate outer block image and call next matching template
     note:		If the schema specialization has empty inline elements, you should append its class here! 
     -->
    <xsl:template match="*[contains(@class,' topic/image ') or contains(@class,' topic/xref ')]
        [ahf:hasDitaValStartPropWithImageFlag(.) or ahf:hasDitaValEndPropWithImageFlag(.)]" 
        priority="20">
        <xsl:for-each select="ahf:getStartFlagWithImage(.)">
            <xsl:call-template name="genInlineLevelImageOrTextForFlagging">
                <xsl:with-param name="prmFlagElem" select="."/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:next-match/>
        <xsl:for-each select="ahf:getEndFlagWithImage(.)">
            <xsl:call-template name="genInlineLevelImageOrTextForFlagging">
                <xsl:with-param name="prmFlagElem" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	Generate inline level flag image or text 
     param:		prmFlagElem (startflag or endflag)
     return:	generated image or p elements
     note:		Treat image as relative to map if it does not begin with "https:/", "http:/", "ftp:/", "file:/".
     -->
    <xsl:template name="genInlineLevelImageOrTextForFlagging" as="element()?">
        <xsl:param name="prmFlagElem" as="element()?" required="yes"/>
        <xsl:choose>
            <xsl:when test="exists($prmFlagElem/@dita-ot:imagerefuri)">
                <xsl:variable name="imageRefUri" as="xs:string" select="string($prmFlagElem/@dita-ot:imagerefuri)"/>
                <image xsl:use-attribute-sets="atsFlagInlineImage">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="ahf:isAbsUri($imageRefUri)">
                                <xsl:value-of select="$imageRefUri"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($pMapDirUrl,$imageRefUri)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="$prmFlagElem/alt-text">
                        <alt xsl:use-attribute-sets="atsAlt">
                            <xsl:copy-of select="$prmFlagElem/alt-text/node()"/>
                        </alt>
                    </xsl:if>
                </image>
            </xsl:when>
            <xsl:when test="string(normalize-space(string($prmFlagElem/alt-text)))">
                <ph xsl:use-attribute-sets="atsPh">
                    <xsl:copy-of select="$prmFlagElem/alt-text/node()"/>
                    <xsl:text>&#x20;</xsl:text>
                </ph>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
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
    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" priority="10">
        <xsl:message select="'[ditaval-startprop] Hit!'"/>
        <xsl:call-template name="genInlineLevelImageOrTextForFlagging">
            <xsl:with-param name="prmFlagElem" select="*[self::prop or self::revprop]/startflag"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" priority="10">
        <xsl:message select="'[ditaval-endprop] Hit!'"/>
        <xsl:call-template name="genInlineLevelImageOrTextForFlagging">
            <xsl:with-param name="prmFlagElem" select="*[self::prop or self::revprop]/endflag"/>
        </xsl:call-template>
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
     function:	Template for element that has effective ditaval-startprop element as child
     param:		none
     return:	copied result
     note:		This template generates style from .ditaval prop or revprop/action="flag" element's style.
                This style is passed as $prmDitaValFlagStyle tunnel parameter.
                This template also generates style from .ditaval revprop/action="flag" element's change-bar style.
                This style is passed as $prmDitaValChangeBarStyle tunnel parameter.
                The priority 20 is defined in comparison with dita2fo_convmerged.xsl default templete (match="*").
     -->
    <xsl:template match="*[ahf:hasChildDitaValStartProp(.)]" priority="20">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="ditaValPropOrRevProp" as="element()*" select="ahf:getGrandChildDitavalPropOrRevProp(.)"/>
        <xsl:variable name="ditaValFlagStyle" as="xs:string" select="ahf:getDitaValFlagStyle($ditaValPropOrRevProp)"/>
        <xsl:variable name="ditaValRevProp" as="element()*" select="ahf:getGrandChildDitavalRevProp(.)"/>
        <xsl:variable name="ditaValChangeBarStyle" as="xs:string" select="ahf:getDitaValChangeBarStyle($ditaValRevProp)"/>
        <xsl:next-match>
            <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="concat($prmDitaValFlagStyle,$ditaValFlagStyle)"/>
            <xsl:with-param name="prmDitaValChangeBarStyle" tunnel="yes" select="$ditaValChangeBarStyle"/>
        </xsl:next-match>
    </xsl:template>

    <!-- 
     function:	Check child has ditava-startprop element
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasChildDitaValStartProp" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists($prmElem/*[1][contains(@class, ' ditaot-d/ditaval-startprop ')]/*[self::prop or self::revprop])"/>
    </xsl:function>
    
    <!-- 
     function:	Get grand child ditava-startprop/prop or revprop element
     param:		prmElem
     return:	element()*
     note:		Return grand child ditaval-startprop/prop, revprop element.
     -->
    <xsl:function name="ahf:getGrandChildDitavalPropOrRevProp" as="element()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[contains(@class, ' ditaot-d/ditaval-startprop ')]/*[self::prop or self::revprop]"/>
    </xsl:function>

    <!-- 
     function:	Get grand child ditava-startprop/revprop element
     param:		prmElem
     return:	element()*
     note:		Return grand child ditaval-startprop/revprop element.
     -->
    <xsl:function name="ahf:getGrandChildDitavalRevProp" as="element()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[contains(@class, ' ditaot-d/ditaval-startprop ')]/*[self::revprop]"/>
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
        <xsl:variable name="foProp" as="xs:string" select="string($prmElem/@*[name() eq $pFoPropName])"/>
        <xsl:choose>
            <xsl:when test="string($foProp)">
                <xsl:sequence select="concat($foProp,if (ends-with($foProp,';')) then '' else ';',$prmDitaValFlagStyle)"/>
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
        <xsl:param name="prmDitaValPropOrRevProps" as="element()*"/>
        <xsl:variable name="styleProps" as="xs:string*">
            <xsl:for-each select="$prmDitaValPropOrRevProps">
                <xsl:variable name="ditaValPropOrRevProp" as="element()" select="."/>
                <xsl:variable name="color" as="xs:string">
                    <xsl:variable name="colorVal" as="xs:string" select="normalize-space(string($ditaValPropOrRevProp/@color))"/>
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
                    <xsl:variable name="backColorVal" as="xs:string" select="normalize-space(string($ditaValPropOrRevProp/@backcolor))"/>
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
                    <xsl:variable name="styleVal" as="xs:string" select="normalize-space(string($ditaValPropOrRevProp/@style))"/>
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
                        <xsl:when test="$styleVal eq 'line-through'">
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
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($styleProps,'')"/>
    </xsl:function>

    <!-- 
     function:	Generate CSS style notation from ditaval-startprop/revprop/@changebar attribute
     param:		prmDitaValRevProps (revprop elements)
     return:	xs:string
     note:		Invalid property for fo:change-bar-start is removed.
     -->
    <xsl:function name="ahf:getDitaValChangeBarStyle" as="xs:string">
        <xsl:param name="prmDitaValRevProps" as="element()*"/>
        <xsl:variable name="styleProps" as="xs:string*">
            <xsl:for-each select="$prmDitaValRevProps">
                <xsl:variable name="ditaValRevProp" as="element()" select="."/>
                <xsl:variable name="changeBarAttVal" as="xs:string" select="normalize-space(string($ditaValRevProp/@changebar))"/>
                <xsl:for-each select="tokenize($changeBarAttVal, ';')">
                    <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
                    <xsl:choose>
                        <xsl:when test="not(string($propDesc))"/>
                        <xsl:when test="contains($propDesc,':')">
                            <xsl:variable name="propName" as="xs:string">
                                <xsl:variable name="tempPropName" as="xs:string" select="substring-before($propDesc,':')"/>
                                <xsl:variable name="axfExt" as="xs:string" select="'axf-'"/>
                                <xsl:variable name="ahsExt" as="xs:string" select="'ahs-'"/>
                                <xsl:choose>
                                    <xsl:when test="starts-with($tempPropName,$axfExt)">
                                        <xsl:sequence select="concat('axf:',substring-after($tempPropName,$axfExt))"/>
                                    </xsl:when>
                                    <xsl:when test="starts-with($tempPropName,$ahsExt)">
                                        <xsl:sequence select="''"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$tempPropName"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>                            
                            <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                            <xsl:choose>
                                <xsl:when test="$propName = ('change-bar-color','change-bar-offset','change-bar-placement','change-bar-style','change-bar-width','z-index')">
                                    <xsl:sequence select="concat($propName,':',$propValue,';')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes810,('%changeBarAttr'),($changeBarAttVal))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($styleProps,'')"/>
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
        <xsl:sequence select="some $startflag in $prmElem/*[contains(@class,' ditaot-d/ditaval-startprop ')]/*[self::prop or self::revprop]/startflag satisfies (exists($startflag/@imageref) or string(normalize-space(string($startflag/alt-text))))"/>
    </xsl:function>
    
    <xsl:function name="ahf:hasDitaValWithImageEndFlag" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="some $endflag in $prmElem//*[contains(@class,' ditaot-d/ditaval-endprop ')]/*[self::prop or self::revprop]/endflag satisfies (exists($endflag/@imageref) or string(normalize-space(string($endflag/alt-text))))"/>
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
        <xsl:sequence select="$prmElem/*[contains(@class,' ditaot-d/ditaval-startprop ')]/*[self::prop or self::revprop]/startflag"/>
    </xsl:function>
    
    <xsl:function name="ahf:getEndFlagWithImage" as="element()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/*[contains(@class,' ditaot-d/ditaval-endprop ')]/*[self::prop or self::revprop]/endflag"/>
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
