<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf"
    >

    <!-- 
         function:	Expand FO style & property into attribute()*
         param:		prmElem
         return:	Attribute node
         note:		Style is authored in $prmElem/@fo:style
                    XSL-FO attribute is authored in $prmElem/@fo:prop in CSS notation.
                    2014-09-13 t.makita
                    Changed attributename:
                    fo⇒fo:prop
                    fo-style⇒fo:style
                    2014-10-04 t.makita
    -->
    <xsl:template name="ahf:getFoStyleAndProperty" as="attribute()*">
        <xsl:param name="prmElem" required="no" as="element()" select="."/>
        <xsl:sequence select="ahf:getFoStyleAndProperty($prmElem)"/>
    </xsl:template>
    
    <xsl:function name="ahf:getFoStyleAndProperty" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getFoStyle($prmElem)"/>
        <xsl:sequence select="ahf:getFoProperty($prmElem)"/>
        <xsl:sequence select="$prmElem/@axf:*"/>
    </xsl:function>

    <!-- 
         function:	Expand FO style into attribute()*
         param:		prmElem
         return:	Attribute node
         note:		Style is authored in $prmElem/@fo:style
                    2014-09-13 t.makita
    -->
    <xsl:function name="ahf:getFoStyle">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:choose>
            <xsl:when test="exists($prmElem/@*[name() eq $pFoStyleName])">
                <xsl:sequence select="ahf:getAttributeSet(string($prmElem/@*[name() eq $pFoStyleName]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
         function:	Expand FO property into attribute()*
         param:		prmElem
         return:	Attribute node
         note:		XSL-FO attribute is authored in $prmElem/@fo:prop in CSS notation.
                    2014-04-22 t.makita
                    Remove stylesheet specific style (starts with "ahs-").
                    2016-02-20 t,makita
    -->
    <xsl:function name="ahf:getFoProperty" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        
        <xsl:choose>
            <xsl:when test="exists($prmElem/@*[name() eq $pFoPropName])">
                <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmElem/@*[name() eq $pFoPropName]))"/>
                <xsl:for-each select="tokenize($foAttr, ';')">
                    <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
                    <xsl:choose>
                        <xsl:when test="not(string($propDesc))"/>
                        <xsl:when test="contains($propDesc,':')">
                            <xsl:variable name="propName" as="xs:string">
                                <xsl:variable name="tempPropName" as="xs:string" select="normalize-space(substring-before($propDesc,':'))"/>
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
                                <xsl:when test="not(string($propName))"/>
                                <!--"castable as xs:NAME" can be used only in Saxon PE or EE.
                                    If $propName does not satisfy above, xsl:attribute instruction will be faild!
                                    2014-04-22 t.makita
                                 -->
                                <!--xsl:when test="$propName castable as xs:NAME"-->
                                <xsl:when test="true()">
                                    <xsl:attribute name="{$propName}" select="$propValue"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="warningContinue">
                                        <xsl:with-param name="prmMes" select="ahf:replace($stMes802,('%propName','%xtrc','%xtrf'),($propName,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes800,('%foAttr','%xtrc','%xtrf'),($foAttr,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
         function:	Expand FO property into attribute()*
                    Replacing text() with given parameters ($prmSrc, $prmDst).
         param:		prmElem,$prmSrc,$prmDst
         return:	Attribute node
         note:		XSL-FO attribute is authored in $prmElem/@fo:prop in CSS notation.
                    2014-04-22 t.makita
    -->
    <xsl:function name="ahf:getFoPropertyReplacing" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="xs:string+"/>
        
        <xsl:choose>
            <xsl:when test="exists($prmElem/@*[name() eq $pFoPropName])">
                <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmElem/@*[name() eq $pFoPropName]))"/>
                <xsl:for-each select="tokenize($foAttr, ';')">
                    <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
                    <xsl:choose>
                        <xsl:when test="not(string($propDesc))"/>
                        <xsl:when test="contains($propDesc,':')">
                            <xsl:variable name="propName" as="xs:string">
                                <xsl:variable name="tempPropName" as="xs:string" select="normalize-space(substring-before($propDesc,':'))"/>
                                <xsl:variable name="axfExt" as="xs:string" select="'axf-'"/>
                                <xsl:choose>
                                    <xsl:when test="starts-with($tempPropName,$axfExt)">
                                        <xsl:sequence select="concat('axf:',substring-after($tempPropName,$axfExt))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$tempPropName"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>                            
                            <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                            <xsl:choose>
                                <!--"castable as xs:NAME" can be used only in Saxon PE or EE.
                                    If $propName does not satisfy above, xsl:attribute instruction will be faild!
                                    2014-04-22 t.makita
                                 -->
                                <!--xsl:when test="$propName castable as xs:NAME"-->
                                <xsl:when test="true()">
                                    <xsl:variable name="propReplaceResult" as="xs:string" select="ahf:replace($propValue,$prmSrc,$prmDst)"/>
                                    <xsl:attribute name="{$propName}" select="$propReplaceResult"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="warningContinue">
                                        <xsl:with-param name="prmMes" select="ahf:replace($stMes806,('%propName','%xtrc','%xtrf'),($propName,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes804,('%foAttr','%xtrc','%xtrf'),($foAttr,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
         function:	Expand FO property into attribute()*
                    Replacing text() with given page related parameters.
                    %paper-width is replaced with $pPaperWidth
                    %paper-height is replaced with $pPaperHeight
                    %crop-size-h is replaced with $pCropSizeH
                    %crop-size-v is replaced with $pCropSizeV
                    %bleed-size is replaced with $pBleedSize
         param:		prmElem
         return:	Attribute node
         note:		Used for making cover page：page size (width,height), cop size (horizontal,vertical), bleed size are replaced by actual value and returned as attribute()*.
                    This function refers global variable $pPaperWidth,$pPaperHeight,$pCropSizeH,$pCropSizeV,$pBleedSize.（dita2fo_param.xsl)
                    Authoring "0.5 * %paper-width" will get half width of page size.
    -->
    <xsl:function name="ahf:getFoPropertyWithPageVariables" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getFoStyle($prmElem)"/>
        <xsl:sequence select="ahf:getFoPropertyReplacing($prmElem,
            ('%paper-width','%paper-height','%crop-size-h','%crop-size-v','%bleed-size'),
            ($pPaperWidth,$pPaperHeight,$pCropSizeH,$pCropSizeV,$pBleedSize))"/>
    </xsl:function>
    

    <!-- 
         function:	Expand stylesheet specific property into attribute()*
                    Stylesheet oriented property has prefix "ahs-" as its signature and written in fo:prop attribute for convenience.
         param:		prmElem
         return:	Attribute node ("http://www.antennahouse.com/names/XSLT/Document/Layout" namespace)
         note:		Stylesheet specific property is not XSL-FO property.
                    It is used to override the style defined default_style.xml or others. 
                    2016-02-20 t,makita
    -->
    <xsl:function name="ahf:getStylesheetProperty" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        
        <xsl:choose>
            <xsl:when test="exists($prmElem/@*[name() eq $pFoPropName])">
                <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmElem/@*[name() eq $pFoPropName]))"/>
                <xsl:message select="'$foAttr=',$foAttr"></xsl:message>
                <xsl:for-each select="tokenize($foAttr, ';')">
                    <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
                    <xsl:choose>
                        <xsl:when test="not(string($propDesc))"/>
                        <xsl:when test="contains($propDesc,':')">
                            <xsl:variable name="propName" as="xs:string">
                                <xsl:variable name="tempPropName" as="xs:string" select="normalize-space(substring-before($propDesc,':'))"/>
                                <xsl:variable name="ahsExt" as="xs:string" select="'ahs-'"/>
                                <xsl:choose>
                                    <xsl:when test="starts-with($tempPropName,$ahsExt)">
                                        <xsl:sequence select="concat('ahs:',substring-after($tempPropName,$ahsExt))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="''"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>                            
                            <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                            <xsl:choose>
                                <xsl:when test="not(string($propName))"/>
                                <xsl:when test="true()">
                                    <xsl:attribute name="{$propName}" select="$propValue"/>
                                </xsl:when>
                            </xsl:choose>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes800,('%foAttr','%xtrc','%xtrf'),($foAttr,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>