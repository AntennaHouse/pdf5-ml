<?xml version="1.0" encoding="UTF-8" ?>
<!--
	****************************************************************
	DITA to XSL-FO Stylesheet
	Module: Stylesheet for expanding style definition file.
	Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
	Antenna House is a trademark of Antenna House, Inc.
	URL    : http://www.antennahouse.com/
	E-mail : info@antennahouse.com
	****************************************************************
	The expanded result will be stored into:
	$glVarDefs: Variable
	$glStyleDefs: Attribute set
	****************************************************************
-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahp="http://www.antennahouse.com/names/XSLT/Document/PageControl"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:style="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs style"
>
	<!--============================================
	     External dependencies:
	     $PRM_STYLE_DEF_FILE (dita2fo_param.xsl)
	     $documetLang (dita2fo_global.xsl)
	    ============================================-->
	<!--============================================
	     Constants
	    ============================================-->
	<!-- Variable reference symbol -->
	<xsl:variable name="varRefChar" select="'$'"/>
	<xsl:variable name="varRefEscapeChar" select="'\'"/>
	<!--xsl:variable name="styleRefChar" select="'%'"/-->
	<!-- Default delimiter：space -->
	<xsl:variable name="defaultDelimChar" select="' ()*+'"/>
	<xsl:variable name="fileUrlPrefix" as="xs:string" select="''"/>
	<!-- Attribute names used in the style definition -->
	<xsl:variable name="styleAttrs" as="xs:string+" select="('use-attribute-sets','name','doc-type','paper-size','output-type','xml:lang')"/>
	<xsl:variable name="varAttrs" as="xs:string+" select="('name','doc-type','paper-size','output-type','delim')"/>
	<!-- Attribute names in the expanded style tree -->
	<xsl:variable name="expandedAttrs" as="xs:string+" select="('name','xml:lang','doc-type','paper-size','output-type','delim')"/>
	<!-- Child element after expanding style -->
	<xsl:variable name="expandedAttrsName" as="xs:string" select="'attribute'"/>
	
	<!-- Plug-in URI: upper hierarchy of this stylesheet. -->
	<xsl:variable name="basePluginUri" as="xs:string" select="string(resolve-uri('../', static-base-uri()))"/>
	
	<!-- Plug-in path description in the attribute. -->
	<xsl:variable name="basePluginPathSymbol" as="xs:string" select="'%plug-in-path%'"/>
	
	<!-- Default style definition file.
		 Path is relative from $basePluginPath
	  -->
	<xsl:variable name="styleDefFile" as="xs:string" select="ahf:bsToSlash($PRM_STYLE_DEF_FILE)"/>
	
	<xsl:variable name="styleDefFileUri" as="xs:string">
		<xsl:variable name="tempStyleDefFileUri" select="concat($basePluginUri,$styleDefFile)" as="xs:string"/>
		<xsl:if test="$pDebug">
			<xsl:message select="'Plug-in URI=',$basePluginUri"/>
			<xsl:message select="'styleDefFile=',$styleDefFile"/>
			<xsl:message select="'tempStyleDefFileUri=',$tempStyleDefFileUri"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="doc-available($tempStyleDefFileUri)">
				<xsl:sequence select="$tempStyleDefFileUri"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="errorExit">
					<xsl:with-param name="prmMes" 
						select="ahf:replace($stMes104,('%file'),($tempStyleDefFileUri))"/>
				</xsl:call-template>
				<xsl:sequence select="''"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- @xml:lang used in this document.
	  -->
	<xsl:variable name="uniqueXmlLang" as="xs:string*">
		<xsl:variable name="xmlLang" as="xs:string*">
			<xsl:sequence select="$documentLang"/>
			<xsl:for-each select="$map/descendant-or-self::*/@xml:lang
								| $root//*[contains(@class,' topic/topic ')]/descendant-or-self::*/@xml:lang">
				<xsl:sequence select="ahf:nomalizeXmlLang(string(.))"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="distinct-values($xmlLang)">
			<xsl:sequence select="string(.)"/>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Language specific style definition file:
	     This value is obtained from map/@xml:lang, topic/@xml:lang.
	     This parameter has been changed from xsl:param to xsl:variable
	     because there is no needs to pass the value as parameter.
	     2012-12-19 t.makita
	  -->
	<xsl:variable name="altStyleDefFile" as="xs:string*">
		<xsl:for-each select="$uniqueXmlLang">
			<xsl:variable name="xmlLang" as="xs:string" select="string(.)"/>
			<xsl:sequence select="concat('config/',$xmlLang,'_style.xml')"/>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="altStyleDefFileUri" as="xs:string*">
		<xsl:variable name="tempAltStyleDefFileUri" as="xs:string*">
			<xsl:for-each select="$altStyleDefFile">
				<xsl:sequence select="concat($basePluginUri,.)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="$tempAltStyleDefFileUri">
			<xsl:choose>
				<xsl:when test="doc-available(.)">
					<!--xsl:message select="'$prmAltStyleDefFile=',$prmAltStyleDefFile, 'selected!'"/-->
					<xsl:sequence select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="warningContinue">
						<xsl:with-param name="prmMes" 
							select="ahf:replace($stMes105,('%file'),(string(.)))"/>
					</xsl:call-template>
					<xsl:sequence select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Effective xml:lang that has corresponding style definition file.
	  -->
	<xsl:variable name="altXmlLang" as="xs:string*">
		<xsl:for-each select="$altStyleDefFileUri">
			<xsl:choose>
				<xsl:when test="not(string(.))"/>
				<xsl:when test="doc-available(.)">
					<xsl:sequence select="$uniqueXmlLang[position()]"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- For message output -->
	<xsl:variable name="allStyleDefFile" as="xs:string">
		<xsl:choose>
			<xsl:when test="empty($altStyleDefFile)">
				<xsl:sequence select="$styleDefFileUri"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="tempAllStyleDefFile" as="xs:string*">
					<xsl:sequence select="concat($styleDefFileUri, ' and ',$altStyleDefFileUri[1])"/>
					<xsl:for-each select="$altStyleDefFileUri[position() gt 1]">
						<xsl:sequence select="concat(' and ',.)"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:sequence select="string-join($tempAllStyleDefFile,'')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- 
	    =======================================================
	     Temporary tree for style & variable definition 
	    =======================================================
	-->
	<!-- Original variable definition. -->
	<xsl:variable name="glOrgVarDefs" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="document($styleDefFileUri)/*" mode="GET_VARIABLE">
				<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string?" select="()"/>
			</xsl:apply-templates>
			<xsl:for-each select="$altStyleDefFileUri">
				<xsl:if test="string(.)">
					<xsl:variable name="position" as="xs:integer" select="position()"/>
					<xsl:apply-templates select="document(.)/*" mode="GET_VARIABLE">
						<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$uniqueXmlLang[position() eq $position]"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:document>
	</xsl:variable>
	
	<xsl:template match="style:*" mode="GET_VARIABLE">
		<xsl:apply-templates mode="#current"/>
	</xsl:template> 

	<xsl:template match="text()" mode="GET_VARIABLE">
	</xsl:template> 

	<xsl:template match="style:variable" mode="GET_VARIABLE">
		<xsl:param name="prmXmlLang" tunnel="yes" required="yes" as="xs:string?"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="exists($prmXmlLang)">
				<xsl:attribute name="xml:lang" select="$prmXmlLang"/>
			</xsl:if>
			<xsl:copy-of select="child::node()"/>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="style:include[string(@href)]" mode="GET_VARIABLE">
		<xsl:apply-templates select="document(string(@href),.)" mode="#current"/>
	</xsl:template>
		
	<!-- Original style definition
		 Style is expanded over the languages used in the map.
		 They are all correspond to specific language.
		 There is no language neutral styles.
		 2015-01-31 t.makita
	 -->
	<xsl:variable name="glOrgStyleDefs" as="document-node()">
		<xsl:document>
			<xsl:for-each select="$altStyleDefFileUri">
				<xsl:variable name="position" as="xs:integer" select="position()"/>
				<xsl:variable name="xmlLang" as="xs:string" select="$uniqueXmlLang[position() eq $position]"/>
				<xsl:apply-templates select="document($styleDefFileUri)/*" mode="GET_ATTRIBUTE">
					<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$xmlLang"/>
				</xsl:apply-templates>
				<xsl:if test="string(.)">
					<xsl:apply-templates select="document(.)/*" mode="GET_ATTRIBUTE">
						<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$xmlLang"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:document>
	</xsl:variable>
	
	<xsl:template match="style:*" mode="GET_ATTRIBUTE">
		<xsl:apply-templates mode="#current"/>
	</xsl:template> 

	<xsl:template match="text()" mode="GET_ATTRIBUTE">
	</xsl:template> 
	
	<xsl:template match="style:attribute-set" mode="GET_ATTRIBUTE">
		<xsl:param name="prmXmlLang" tunnel="yes" required="yes" as="xs:string?"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="exists($prmXmlLang)">
				<xsl:attribute name="xml:lang" select="$prmXmlLang"/>
			</xsl:if>
			<xsl:copy-of select="child::node()"/>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="style:include[string(@href)]" mode="GET_ATTRIBUTE">
		<xsl:apply-templates select="document(concat($fileUrlPrefix,string(@href)),.)" mode="#current"/>
	</xsl:template>

	<!-- Original instream objects -->
	<xsl:variable name="glOrgInstreamObjects">
		<xsl:document>
			<xsl:apply-templates select="document($styleDefFileUri)/*" mode="GET_INSTREAM_OBJECTS">
				<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string?" select="()"/>
			</xsl:apply-templates>
			<xsl:for-each select="$altStyleDefFileUri">
				<xsl:if test="string(.)">
					<xsl:variable name="position" as="xs:integer" select="position()"/>
					<xsl:apply-templates select="document(.)/*" mode="GET_INSTREAM_OBJECTS">
						<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$uniqueXmlLang[position() eq $position]"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:document>
	</xsl:variable>
	
	<xsl:template match="style:*" mode="GET_INSTREAM_OBJECTS">
		<xsl:apply-templates mode="#current"/>
	</xsl:template> 

	<xsl:template match="text()" mode="GET_INSTREAM_OBJECTS">
	</xsl:template> 
	
	<xsl:template match="style:instream-object" mode="GET_INSTREAM_OBJECTS">
		<xsl:param name="prmXmlLang" tunnel="yes" required="yes" as="xs:string?"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="exists($prmXmlLang)">
				<xsl:attribute name="xml:lang" select="$prmXmlLang"/>
			</xsl:if>
			<xsl:copy-of select="child::node()"/>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="style:include[string(@href)]" mode="GET_INSTREAM_OBJECTS">
		<xsl:apply-templates select="document(string(@href),.)" mode="#current"/>
	</xsl:template>

	<!-- Original formatting objects -->
	<xsl:variable name="glOrgFormattingObjects">
		<xsl:document>
			<xsl:apply-templates select="document($styleDefFileUri)/*" mode="GET_FORMATTING_OBJECTS">
				<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string?" select="()"/>
			</xsl:apply-templates>
			<xsl:for-each select="$altStyleDefFileUri">
				<xsl:if test="string(.)">
					<xsl:variable name="position" as="xs:integer" select="position()"/>
					<xsl:apply-templates select="document(.)/*" mode="GET_FORMATTING_OBJECTS">
						<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$uniqueXmlLang[position() eq $position]"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:document>
	</xsl:variable>
	
	<xsl:template match="style:*" mode="GET_FORMATTING_OBJECTS">
		<xsl:apply-templates mode="#current"/>
	</xsl:template> 

	<xsl:template match="text()" mode="GET_FORMATTING_OBJECTS">
	</xsl:template> 
	
	<xsl:template match="style:formatting-object" mode="GET_FORMATTING_OBJECTS">
		<xsl:param name="prmXmlLang" tunnel="yes" required="yes" as="xs:string?"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="exists($prmXmlLang)">
				<xsl:attribute name="xml:lang" select="$prmXmlLang"/>
			</xsl:if>
			<xsl:copy-of select="child::node()"/>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="style:include[string(@href)]" mode="GET_FORMATTING_OBJECTS">
		<xsl:apply-templates select="document(string(@href),.)" mode="#current"/>
	</xsl:template>

	<!-- Original XML objects -->
	<xsl:variable name="glOrgXmlObjects">
		<xsl:document>
			<xsl:apply-templates select="document($styleDefFileUri)/*" mode="GET_XML_OBJECTS">
				<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string?" select="()"/>
			</xsl:apply-templates>
			<xsl:for-each select="$altStyleDefFileUri">
				<xsl:if test="string(.)">
					<xsl:variable name="position" as="xs:integer" select="position()"/>
					<xsl:apply-templates select="document(.)/*" mode="GET_XML_OBJECTS">
						<xsl:with-param name="prmXmlLang" tunnel="yes" as="xs:string" select="$uniqueXmlLang[position() eq $position]"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:document>
	</xsl:variable>
	
	<xsl:template match="style:*" mode="GET_XML_OBJECTS">
		<xsl:apply-templates mode="#current"/>
	</xsl:template> 

	<xsl:template match="text()" mode="GET_XML_OBJECTS">
	</xsl:template> 
	
	<xsl:template match="style:xml-object" mode="GET_XML_OBJECTS">
		<xsl:param name="prmXmlLang" tunnel="yes" required="yes" as="xs:string?"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="exists($prmXmlLang)">
				<xsl:attribute name="xml:lang" select="$prmXmlLang"/>
			</xsl:if>
			<xsl:copy-of select="child::node()"/>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="style:include[string(@href)]" mode="GET_XML_OBJECTS">
		<xsl:apply-templates select="document(string(@href),.)" mode="#current"/>
	</xsl:template>

	<!-- 
	    =======================================================
	     Temporary tree of variable & style that references 
	     are resolved. 
	    =======================================================
	-->
	<xsl:variable name="glVarDefs" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$glOrgVarDefs/style:variable" mode="MAKE_DEFINITION">
			</xsl:apply-templates>
		</xsl:document>
	</xsl:variable>
	
	<xsl:variable name="glStyleDefs" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$glOrgStyleDefs/style:attribute-set" mode="MAKE_DEFINITION">
			</xsl:apply-templates>	
		</xsl:document>
	</xsl:variable>

	<xsl:variable name="glInstreamObjects" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$glOrgInstreamObjects/style:instream-object" mode="MAKE_DEFINITION">
			</xsl:apply-templates>	
		</xsl:document>
	</xsl:variable>

	<xsl:variable name="glFormattingObjects" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$glOrgFormattingObjects/style:formatting-object" mode="MAKE_DEFINITION">
			</xsl:apply-templates>	
		</xsl:document>
	</xsl:variable>

	<xsl:variable name="glXmlObjects" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$glOrgXmlObjects/style:xml-object" mode="MAKE_DEFINITION">
			</xsl:apply-templates>	
		</xsl:document>
	</xsl:variable>

	<!-- 
	     style:instream-object,style:formatting-object,style:xml-object template
	     Generate element name: instream-object,formatting-object,xml-object
	     Notes: Only copy the contents.
	  -->
	<xsl:template match="style:instream-object|style:formatting-object|style:xml-object" mode="MAKE_DEFINITION">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*[name() = $expandedAttrs]"/>
			<xsl:copy-of select="child::node()"/>
		</xsl:element>
	</xsl:template>
	
	<!-- 
	     style:variable template
	     Generate element name: variable
	     Generate attribute: style:variable/@*
	     Generate text: style:variable/text()
	     Notes: If a variable text contains "$", it is treated as variable reference and actual valiable value is embedded.
	            If a variable text contains "%plug-in-path%", treat it as plug-in base path and convert it into absolute path.
	            For example:
	            %plug-in-path%common-graphic/hello.png
	            will be converted into
	            file:/D:/DITA-OT1.6.3/plugins/com.atennahouse.pdf5/common-graphic/hello.png
	            (Variable references and stylesheet base path is exclusive.)
	  -->
	<xsl:template match="style:variable" mode="MAKE_DEFINITION">
		<xsl:variable name="varElem" as="element()" select="."/>
		<xsl:variable name="varValue" select="if (@select) then string(@select) else string(.)"/>
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*[name() = $expandedAttrs]"/>
			<xsl:choose>
				<!-- If variable value contains variable reference, expand it to get the actual variable value.
				  -->
				<xsl:when test="contains($varValue,$varRefChar)">
					<xsl:call-template name="expandExp">
						<xsl:with-param name="prmExp" select="$varValue"/>
						<xsl:with-param name="prmXmlLang" select="if (exists($varElem/@xml:lang)) then string($varElem/@xml:lang) else $defaultXmlLang"/>
						<xsl:with-param name="prmDocType" select="if (exists($varElem/@document-type)) then string($varElem/@document-type) else $defaultDocType"/>
						<xsl:with-param name="prmPaperSize" select="if (exists($varElem/@paper-size)) then string($varElem/@paper-size) else $defaultPaperSize"/>
						<xsl:with-param name="prmOutputType" select="if (exists($varElem/@output-type)) then string($varElem/@output-type) else $defaultOutputType"/>
					</xsl:call-template>
				</xsl:when>
 
				<!-- '%plug-in-path%' expresses plug-in path. Assume attribute value as path description and expand it into absolute path.
				     Attribute value can have 'url(%plug-in-path%～)' format.
				     This cannnot be processed recursively. '%plug-in-path%' must be written only once.
				  -->
				<xsl:when test="contains($varValue,$basePluginPathSymbol)">
					<xsl:variable name="beforePart" as="xs:string" select="substring-before($varValue,$basePluginPathSymbol)"/>
					<xsl:variable name="afterPart" as="xs:string" select="substring-after($varValue,$basePluginPathSymbol)"/>
					<xsl:variable name="afterUri" as="xs:string" select="if (ends-with($afterPart,')')) then ahf:substringBeforeLast($afterPart,')') else $afterPart"/>
					<xsl:variable name="endCh" as="xs:string" select="if (ends-with($afterPart,')')) then ')' else ''"/>
					<xsl:variable name="absUri" as="xs:string" select="string(resolve-uri($afterUri,$basePluginUri))"/>
					<xsl:value-of select="concat($beforePart,$absUri,$endCh)"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="$varValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- 
	     expandExp template
	     Function： Expand expression that includes variable reference.
	                Variable can be obtained from variable temporary tree ($glOrgVarDefs).
		 Parameter: prmXmlLang: xml:lang 
	                prmDocType: Document type
	                prmPaperSize: Paper size
		 Note:  Variable temporary tree is stored in $glOrgVarDefs.
	            If it has reference to other variable, it will be resolved using parameter $prmXmlLang, $prmDocType and $prmPaperSize.
	            The final target should be unique because it is a variable.
	            The variable references must be delimtered by white-space. For instance:
			    <variable name="index_H_top">$index_K_top + $index_K_height + 0.7mm</variable>
				Below example is not good because there is no white space delimiter.
				<variable name="index_H_top">$index_K_top+$index_K_height+0.7mm</variable>
				Currently the following is not supported.
				<variable name="index_H_top">($index_K_top + $index_K_height) + 0.7mm</variable>
				If you insert a white-space, it will be processed normally.
				<variable name="index_H_top">( $index_K_top + $index_K_height ) + 0.7mm</variable>
	  -->
	<xsl:variable name="expandExpRegX" as="xs:string" select="'[\s\(\),\*\+]+?'"/>
	
	<xsl:template name="expandExp" as="xs:string">
		<xsl:param name="prmExp" required="yes" as="xs:string"/>
		<xsl:param name="prmXmlLang" required="yes" as="xs:string?"/>
		<xsl:param name="prmDocType" required="yes" as="xs:string?"/>
		<xsl:param name="prmPaperSize" required="yes" as="xs:string?"/>
		<xsl:param name="prmOutputType" required="yes" as="xs:string?"/>
		
		<!--xsl:message select="'[expandExp] $prmExp=''',$prmExp,''''"/-->
		<xsl:variable name="tempExpandedExp" as="xs:string*">
			<!-- Tokenize using regular expression -->
			<xsl:analyze-string select="$prmExp" regex="{$expandExpRegX}">
				<!-- White-space or other symbol-->
				<xsl:matching-substring>
					<!--xsl:message select="'[expandExp] match=''',.,''''"/-->
					<xsl:sequence select="."/>
				</xsl:matching-substring>
				<!-- Token that is delimitered by white-space or symbol-->
				<xsl:non-matching-substring>
					<!--xsl:message select="'[expandExp] no-match=''',.,''''"/-->
					<xsl:variable name="token" as="xs:string" select="."/>
					<xsl:choose>
						<!-- Recursively resolve the variable reference -->
						<xsl:when test="starts-with($token,$varRefChar)">
							<xsl:variable name="varName" select="substring-after($token,$varRefChar)"/>
							<xsl:variable name="varValueElements" as="element()*">
								<xsl:variable name="targetElements" as="element()*" select="$glOrgVarDefs/style:variable[string(@name) eq $varName]"/>
								<!-- Variable is not found -->
								<xsl:if test="empty($targetElements)">
									<xsl:call-template name="errorExit">
										<xsl:with-param name="prmMes">
											<xsl:value-of select="ahf:replace($stMes023,('%varname','%stylefile'),($varName, $allStyleDefFile))"/>
										</xsl:with-param>
									</xsl:call-template>
									<xsl:sequence select="()"/>
								</xsl:if>
								<!-- Match only varibale name-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[empty(@doc-type)]
																		[empty(@paper-size)]
																		[empty(@output-type)]
																		"/>
								<!-- Match xml:lang (1)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[empty(@doc-type)]
																		[empty(@paper-size)]
																		[empty(@output-type)]
																		"/>
								<!-- Match doc-type (1)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[empty(@paper-size)]
																		[empty(@output-type)]
																		"/>
								<!-- Match paper-size (1)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[empty(@doc-type)]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[empty(@output-type)]
																		"/>
								<!-- Match output-type (1)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[empty(@doc-type)]
																		[empty(@paper-size)]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match xml:lang, doc-type (2)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[empty(@paper-size)]
																		[empty(@output-type)]
																		"/>
								<!-- Match xml:lang, paper-size (2)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[empty(@doc-type)]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[empty(@output-type)]
																		"/>
								<!-- Match xml:lang, output-type (2)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[empty(@doc-type)]
																		[empty(@paper-size)]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match doc-type, paper-size (2)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[empty(@output-type)]
																		"/>
								<!-- Match doc-type, output-type (2)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[empty(@paper-size)]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match paper-size, output-type (2)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[empty(@doc-type)]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match xml:lang, doc-type, paper-size (3)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[empty(@output-type)]
																		"/>
								<!-- Match xml:lang, doc-type, output-type (3)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[empty(@paper-size)]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match xml:lang, paper-size, output-type (3)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[empty(@doc-type)]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match doc-type, paper-size, output-type (3)-->
								<xsl:sequence select="$targetElements[empty(@xml:lang)]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
								<!-- Match xml:lang, doc-type, paper-size, output-type (4)-->
								<xsl:sequence select="$targetElements[ahf:strEqualAsSeq(string(@xml:lang),string($prmXmlLang))]
																		[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
																		[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
																		[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
																		"/>
							</xsl:variable>
							<xsl:if test="empty($varValueElements)">
								<xsl:message select="'[expandExp] Fatal error! $varName=',$varName,' is empty.'"/>
								<xsl:message select="'$prmXmlLang=',$prmXmlLang"/>
								<xsl:message select="'$prmDocType=',$prmDocType"/>
								<xsl:message select="'$prmPaperSize=',$prmPaperSize"/>
								<xsl:message select="'$prmOutputType=',$prmOutputType"/>
							</xsl:if>
							<!-- Adopt last defined one -->
							<xsl:variable name="varValueElement" select="$varValueElements[position() eq last()]" as="element()"/>
							<xsl:variable name="varValue" select="if ($varValueElement/@select) then string($varValueElement/@select) else string($varValueElement)" as="xs:string"/>
							<xsl:choose>
								<xsl:when test="contains($varValue,$varRefChar)">
									<!-- Variable reference still exits. Call recursively myself. -->
									<xsl:call-template name="expandExp">
										<xsl:with-param name="prmExp" select="$varValue"/>
										<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
										<xsl:with-param name="prmDocType" select="$prmDocType"/>
										<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
										<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="$varValue"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- Adopt token as is if it does not contain any variable reference. -->
						<xsl:otherwise>
							<xsl:sequence select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:sequence select="string-join($tempExpandedExp,'')"/>
	</xsl:template>

	<!-- 
	     style:attribute-set template
	     Generate element: attribute-set
	     Generate attributes:  style:attribute-set/@*
	     Notes: @xml:lang become indispensable in style:attribute-set
	            because styles in $glOrgStyleDefs are all belongs in specific language.
	            2015-01-31 t.makita
	  -->
	<xsl:template match="style:attribute-set"  mode="MAKE_DEFINITION">
		<xsl:variable name="xmlLang" as="xs:string" select="@xml:lang"/>
		<xsl:variable name="docType" as="xs:string?" select="if (exists(@doc-type)) then string(@doc-type) else $defaultDocType"/>
		<xsl:variable name="paperSize" as="xs:string?" select="if (exists(@paper-size)) then string(@paper-size) else $defaultPaperSize"/>
		<xsl:variable name="outputType" as="xs:string?" select="if (exists(@output-type)) then string(@output-type) else $defaultOutputType"/>
		<xsl:variable name="currentElement" as="element()" select="."/>
		<xsl:variable name="name" select="string(@name)" as="xs:string"/>
		<!-- Logical check -->
		<xsl:if test="@*[not(name() = $styleAttrs)]">
	        <xsl:call-template name="errorExit">
	            <xsl:with-param name="prmMes" 
	            	select="ahf:replace($stMes900,('%attribute-set-name','%attribute'),(string(@name),string(name(@*[not(name() = $styleAttrs)][1]))))"/>
	        </xsl:call-template>
		</xsl:if>
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*[name() = $expandedAttrs]"/>
			<xsl:element name="{$expandedAttrsName}">
				<xsl:if test="@use-attribute-sets">
			    	<xsl:for-each select="tokenize(string(@use-attribute-sets), '[,\s]+')">
			    		<xsl:variable name="useAttrSetName" as="xs:string" select="."/>
						<!-- Circular reference check -->
			    		<xsl:if test="$name eq $useAttrSetName">
					        <xsl:call-template name="errorExit">
					            <xsl:with-param name="prmMes" 
					             select="ahf:replace($stMes902,('%attribute-set-name'),($name))"/>
					        </xsl:call-template>
				    	</xsl:if>
	    				<xsl:call-template name="processUseAttributeSet">
	    					<xsl:with-param name="prmAttributeSet" select="$useAttrSetName"/>
	    					<xsl:with-param name="prmCurrentElement" select="$currentElement"/>
	    					<xsl:with-param name="prmXmlLang" select="$xmlLang"/>
	    					<xsl:with-param name="prmDocType" select="$docType"/>
	    					<xsl:with-param name="prmPaperSize" select="$paperSize"/>
	    					<xsl:with-param name="prmOutputType" select="$outputType"/>
	    				</xsl:call-template>
		            </xsl:for-each>
		        </xsl:if>
			    <xsl:apply-templates select="style:attribute">
			    	<xsl:with-param name="prmXmlLang" select="$xmlLang"/>
			    	<xsl:with-param name="prmDocType" select="$docType"/>
			    	<xsl:with-param name="prmPaperSize" select="$paperSize"/>
			    	<xsl:with-param name="prmOutputType" select="$outputType"/>
			    </xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- 
	     processUseAttributeSet template
	     function: Process attribute-set element recursively and returns attribute()*.
	     param: prmAttributeSet：Name of attribute-set
	                 prmCurrentElement：Original attribute-set element (Only used for get root())
	     note: Return attributes that @xml:lang,@doc-type,@paper-size matches.
	  -->
	<xsl:template name="processUseAttributeSet" as="attribute()*">
	    <xsl:param name="prmAttributeSet" required="yes" as="xs:string"/>
	    <xsl:param name="prmCurrentElement" required="yes" as="element()"/>
		<xsl:param name="prmXmlLang" required="yes" as="xs:string"/>
		<xsl:param name="prmDocType" required="yes" as="xs:string?"/>
		<xsl:param name="prmPaperSize" required="yes" as="xs:string?"/>
		<xsl:param name="prmOutputType" required="yes" as="xs:string?"/>
		
		<!--xsl:message select="'[processUseAttributeSet] $prmAttributeSet=',$prmAttributeSet,' $prmXmlLang=',$prmXmlLang,' $prmDocType=',$prmDocType,' $prmPaperSize=',$prmPaperSize"/-->
		<xsl:variable name="attrSetElements" as="element()*" select="root($prmCurrentElement)/style:attribute-set[string(@name) eq $prmAttributeSet][string(@xml:lang) eq string($prmXmlLang)]"/>
		<xsl:variable name="orderedAttrSetElements" as="element()*">
			<xsl:sequence select="$attrSetElements[empty(@doc-type)]
													[empty(@paper-size)]
													[empty(@output-type)]
													"/>
			<xsl:sequence select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
													[empty(@paper-size)]
													[empty(@output-type)]
													 "/>
			<xsl:sequence select="$attrSetElements[empty(@doc-type)]
													[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
													[empty(@output-type)]
													"/>
			<xsl:sequence select="$attrSetElements[empty(@doc-type)]
													[empty(@paper-size)]
													[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
													"/>
			<xsl:sequence select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
													[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
													[empty(@output-type)]
													"/>
			<xsl:sequence select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
													[empty(@paper-size)]
													[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
													"/>
			<xsl:sequence select="$attrSetElements[empty(@doc-type)]
													[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
													[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
													 "/>
			<xsl:sequence select="$attrSetElements[ahf:strEqualAsSeq(string(@doc-type),string($prmDocType))]
													[ahf:strEqualAsSeq(string(@paper-size),string($prmPaperSize))]
													[ahf:strEqualAsSeq(string(@output-type),string($prmOutputType))]
													"/>
		</xsl:variable>
		<xsl:if test="empty($orderedAttrSetElements)">
			<xsl:call-template name="errorExit">
				<xsl:with-param name="prmMes">
					<xsl:value-of select="ahf:replace($stMes904,('%attribute-set-name'),($prmAttributeSet))"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:sequence select="()"/>
		</xsl:if>
		<xsl:apply-templates select="$orderedAttrSetElements" mode="USE-ATTRIBUTE-SETS">
			<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
			<xsl:with-param name="prmDocType" select="$prmDocType"/>
			<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
			<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="style:attribute-set" mode="USE-ATTRIBUTE-SETS" as="attribute()*">
		<xsl:param name="prmXmlLang" required="yes" as="xs:string"/>
		<xsl:param name="prmDocType" required="yes" as="xs:string?"/>
		<xsl:param name="prmPaperSize" required="yes" as="xs:string?"/>
		<xsl:param name="prmOutputType" required="yes" as="xs:string?"/>
		
		<xsl:variable name="currentElement" select="."/>
		<xsl:variable name="name" select="string(@name)" as="xs:string"/>
		<!-- Attribute logical check -->
		<xsl:if test="@*[not(name() = $styleAttrs)]">
	        <xsl:call-template name="errorExit">
	            <xsl:with-param name="prmMes" 
	             select="ahf:replace($stMes900,('%attribute-set-name','%attribute'),(string(@name),string(name(@*[not(name() = $styleAttrs)][1]))))"/>
	        </xsl:call-template>
		</xsl:if>
		<xsl:if test="@use-attribute-sets">
	        <xsl:for-each select="tokenize(string(@use-attribute-sets), '[,\s]+')">
				<!-- Check if one reference oneself. -->
		    	<xsl:if test="$name eq string(.)">
			        <xsl:call-template name="errorExit">
			            <xsl:with-param name="prmMes" 
			             select="ahf:replace($stMes902,('%attribute-set-name'),($name))"/>
			        </xsl:call-template>
		    	</xsl:if>
	            <xsl:call-template name="processUseAttributeSet">
	                <xsl:with-param name="prmAttributeSet" select="string(.)"/>
	                <xsl:with-param name="prmCurrentElement" select="$currentElement"/>
	            	<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
	            	<xsl:with-param name="prmDocType" select="$prmDocType"/>
	            	<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
	            	<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
	            </xsl:call-template>
	        </xsl:for-each>
	    </xsl:if>
	    <xsl:apply-templates select="style:attribute">
	    	<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
	    	<xsl:with-param name="prmDocType" select="$prmDocType"/>
	    	<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
	    	<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
	    </xsl:apply-templates>
	</xsl:template>
	
	<!-- 
	     style:attribute template
	     Generate element name: style:attribute/@name
	     Text: style:attribute/text()
	     Notes: If attribute valle contains "$", treat it as variable reference and gte the actual value of the variable then embed the value in it.
	            If attribute value contains "%style_path%", treate it as stylesheet base path and convert it into absolute path.
   	            For instance the following description
	            %style_path%parts/header/header_kk.pdf
	            will be converted into below:
	            file:/D:/My%20Documents/stylesheet/parts/header/header_kk.pdf
	            (Varibale and stylesheet base path is exclusive. This template cannot handle both.)
	  -->
	<xsl:template match="style:attribute" as="attribute()">
		<xsl:param name="prmXmlLang" required="yes" as="xs:string"/>
		<xsl:param name="prmDocType" required="yes" as="xs:string?"/>
		<xsl:param name="prmPaperSize" required="yes" as="xs:string?"/>
		<xsl:param name="prmOutputType" required="yes" as="xs:string?"/>
		
		<xsl:variable name="attName" as="xs:string" select="string(@name)"/>
		<xsl:variable name="attValue" as="xs:string" select="if (@select) then string(@select) else string(.)"/>
		
		<!--
		<xsl:message>[style:attribute] $attName="<xsl:value-of select="$attName"/>" $attValue="<xsl:value-of select="$attValue"/>"</xsl:message>
		-->
		
		<!-- Saxon HE does not support checking xs:NMTOKEN
			 The PE version will be needed. If invelid attribute name is specified, this stylesheet will cause error 
			 in the next xsl:attribute statement.
		-->
		<!--
		<xsl:if test="not($attName castable as xs:NMTOKEN)">
			<xsl:call-template name="errorExit">
				<xsl:with-param name="prmMes" select="ahf:replace($stMes009,('%att-name','%file'),($attName,$allStyleDefFile))"/>
			</xsl:call-template>
		</xsl:if>
		-->
		
		<xsl:attribute name="{$attName}">
			<xsl:choose>
				<!-- '$' is a variable reference. Get the actual variable value.-->
				<xsl:when test="contains($attValue, $varRefChar)">
					<xsl:variable name="expandedAttValue" as="xs:string">
						<xsl:call-template name="expandVarRef">
							<xsl:with-param name="prmSrcString" select="$attValue"/>
							<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
							<xsl:with-param name="prmDocType" select="$prmDocType"/>
							<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
							<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$expandedAttValue"/>
				</xsl:when>
				<!-- '%style_path%' is a stylesheet path. Assume it as path description and convert it into absolute path.
				     Consider the patter that has following pattern: 'url(%style_path%～)'
				  -->
				<xsl:when test="contains($attValue,$basePluginPathSymbol)">
					<xsl:variable name="beforePart" as="xs:string" select="substring-before($attValue,$basePluginPathSymbol)"/>
					<xsl:variable name="afterPart" as="xs:string" select="substring-after($attValue,$basePluginPathSymbol)"/>
					<xsl:variable name="afterUri" as="xs:string" select="if (ends-with($afterPart,')')) then ahf:substringBeforeLast($afterPart,')') else $afterPart"/>
					<xsl:variable name="endCh" as="xs:string" select="if (ends-with($afterPart,')')) then ')' else ''"/>
					<xsl:variable name="absUri" as="xs:string" select="string(resolve-uri($afterUri,$basePluginUri))"/>
					<xsl:value-of select="concat($beforePart,$absUri,$endCh)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$attValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<!-- 
	     expandVarRef template
	     Function: Recursively process the varible reference and return the result text.
	     Parameter: prmSrcString：String that contains variable reference.
	                prmAttributeSetElem：Original attribute-set element. (Used to get variable)
	     Notes:  $prmSrcString can contain multiple variable reference. They must delimited by space.
	  -->
	<xsl:template name="expandVarRef" as="xs:string">
		<xsl:param name="prmSrcString" required="yes" as="xs:string"/>
		<xsl:param name="prmXmlLang" required="yes" as="xs:string"/>
		<xsl:param name="prmDocType" required="yes" as="xs:string?"/>
		<xsl:param name="prmPaperSize" required="yes" as="xs:string?"/>
		<xsl:param name="prmOutputType" required="yes" as="xs:string?"/>
		
		<xsl:variable name="tempExpandedExp" as="xs:string*">
			<!-- Tokenize using regular expression -->
			<xsl:analyze-string select="$prmSrcString" regex="{$expandExpRegX}">
				<!-- White-space or other symbol-->
				<xsl:matching-substring>
					<xsl:sequence select="."/>
				</xsl:matching-substring>
				<!-- Token that is delimitered by white-space or symbol-->
				<xsl:non-matching-substring>
					<xsl:variable name="token" as="xs:string" select="."/>
					<xsl:choose>
						<!-- Resolve the variable reference -->
						<xsl:when test="starts-with($token,$varRefChar)">
							<xsl:variable name="varName" select="substring-after($token,$varRefChar)"/>
							<xsl:variable name="varValue" as="xs:string">
								<xsl:call-template name="getVarValue">
									<xsl:with-param name="prmVarName" select="$varName"/>
									<xsl:with-param name="prmXmlLang" select="$prmXmlLang"/>
									<xsl:with-param name="prmDocType" select="$prmDocType"/>
									<xsl:with-param name="prmPaperSize" select="$prmPaperSize"/>
									<xsl:with-param name="prmOutputType" select="$prmOutputType"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:sequence select="$varValue"/>
						</xsl:when>
						<!-- Not variable -->
						<xsl:otherwise>
							<xsl:sequence select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:sequence select="string-join($tempExpandedExp,'')"/>
	</xsl:template>
	
	<!-- 
	     styleDump template
	     function: Save $glVarDefs, $glStyleDefs, $glInstreamObjects, glFormattingObjects, glXmlObjects to file for debugging.
	     param: none
	     note:
	  -->
	<xsl:template name="stlyeDump">
		<xsl:message>[styleDump] Saving $glVarDefs, $glStyleDefs, $glInstreamObjects, glFormattingObjects, glXmlObjects to file.</xsl:message>

		<!-- varibale -->
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no"
			indent="yes"
			href="OrgVarDefs.xml">
			<root>
				<xsl:copy-of select="$glOrgVarDefs"/>
			</root>
		</xsl:result-document>
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no"
			indent="yes"
			href="VarDefs.xml">
			<root>
				<xsl:copy-of select="$glVarDefs"/>
			</root>
		</xsl:result-document>
		
		<!-- style -->
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="OrgStyleDefs.xml">
			<root>
				<xsl:copy-of select="$glOrgStyleDefs"/>
			</root>
		</xsl:result-document>
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="StyleDefs.xml">
			<root>
				<xsl:copy-of select="$glStyleDefs"/>
			</root>
		</xsl:result-document>
		
		<!-- instream object -->
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="OrgInstreamObjects.xml">
			<root>
				<xsl:copy-of select="$glOrgInstreamObjects"/>
			</root>
		</xsl:result-document>
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="InstreamObjects.xml">
			<root>
				<xsl:copy-of select="$glInstreamObjects"/>
			</root>
		</xsl:result-document>
		
		<!-- formatting object -->
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="OrgFormattingObjects.xml">
			<root>
				<xsl:copy-of select="$glOrgFormattingObjects"/>
			</root>
		</xsl:result-document>
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="FormattingObjects.xml">
			<root>
				<xsl:copy-of select="$glFormattingObjects"/>
			</root>
		</xsl:result-document>
		
		<!-- XML object -->
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="OrgXmlObjects.xml">
			<root>
				<xsl:copy-of select="$glOrgXmlObjects"/>
			</root>
		</xsl:result-document>
		<xsl:result-document 
			method="xml" 
			encoding="UTF-8" 
			byte-order-mark="no" 
			indent="yes"
			href="XmlObjects.xml">
			<root>
				<xsl:copy-of select="$glXmlObjects"/>
			</root>
		</xsl:result-document>
	</xsl:template>
	
	<!--
	 function:	Get nomalized xml:lang 
	 param:		prmXmlLang
	 return:	Normalized xml:lang value
	 note:		
	 -->
	<xsl:function name="ahf:nomalizeXmlLang" as="xs:string">
		<xsl:param name="prmXmlLang" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="contains($prmXmlLang,'-')">
				<xsl:sequence select="concat(lower-case(substring-before($prmXmlLang,'-')),'-',upper-case(substring-after($prmXmlLang,'-')))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="lower-case($prmXmlLang)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!--
	 function:	Compare two strings as sequence of strings 
	 param:		prmSrc, prmDst
	 return:	xs:boolean
	 note:		If $prmSrc exists in $prmDst, returns true().
	            Ex)
	            $prmSrc="ABC"
	            $prmDst="ABC DEF GHI"
	            Result: true()
	            $prmSrc="XYZ"
	            $prmDst="ABC DEF GHI"
	            Result: false()
	            
	            ahf:strNotEqualAsSeq returns true when there is no same members 
	            between two sequence generatetd from $prmSrc and $prmDst.
	 -->
	<xsl:function name="ahf:strEqualAsSeq" as="xs:boolean">
		<xsl:param name="prmSrc" as="xs:string"/>
		<xsl:param name="prmDst" as="xs:string"/>
		<xsl:variable name="srcExpanded" as="xs:string*">
			<xsl:for-each select="tokenize($prmSrc, '[\s]+')">
				<xsl:sequence select="."/>
			</xsl:for-each>	
		</xsl:variable>
		<xsl:variable name="dstExpanded" as="xs:string*">
			<xsl:for-each select="tokenize($prmDst, '[\s]+')">
				<xsl:sequence select="."/>
			</xsl:for-each>	
		</xsl:variable>
		<xsl:sequence select="$srcExpanded = $dstExpanded"/>
	</xsl:function>

	<xsl:function name="ahf:strNotEqualAsSeq" as="xs:boolean">
		<xsl:param name="prmSrc" as="xs:string"/>
		<xsl:param name="prmDst" as="xs:string"/>
		<xsl:variable name="srcExpanded" as="xs:string*">
			<xsl:for-each select="tokenize($prmSrc, '[\s]+')">
				<xsl:sequence select="."/>
			</xsl:for-each>	
		</xsl:variable>
		<xsl:variable name="dstExpanded" as="xs:string*">
			<xsl:for-each select="tokenize($prmDst, '[\s]+')">
				<xsl:sequence select="."/>
			</xsl:for-each>	
		</xsl:variable>
		<xsl:sequence select="not($srcExpanded = $dstExpanded)"/>
	</xsl:function>
	

</xsl:stylesheet>
