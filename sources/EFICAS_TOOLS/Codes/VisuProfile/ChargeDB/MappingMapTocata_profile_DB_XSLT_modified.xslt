<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:ns0="http://chercheurs.edf.com/logiciels/ProfileDB" 
xmlns:ns1="http://chercheurs.edf.com/logiciels/ProfileNS" 
xmlns:tbf="http://chercheurs.edf.com/logiciels/tbf"
xmlns:user="http://chercheurs.edf.com/logiciels/user" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" 
exclude-result-prefixes="ns0 ns1 tbf user xs fn">

	<xsl:output method="xml" encoding="UTF-8" byte-order-mark="no" indent="yes"/>

	<xsl:template name="tbf:raw_copy">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="ns1:*">
			<xsl:element name="{local-name()}" xmlns="http://chercheurs.edf.com/logiciels/ProfileDB" >
				<xsl:call-template name="tbf:raw_copy">
					<xsl:with-param name="input" select="@* | node()"/>
				</xsl:call-template>
				<xsl:for-each select="./@*">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:for-each>
				<xsl:value-of select="text()[fn:normalize-space()]"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="tbf:tbf1_T_total_cpu_time">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_total_cpu_time">
			<xsl:attribute name="unite_T_total_cpu_time" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf2_T_malloc_size">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_malloc_size">
			<xsl:attribute name="unite_T_malloc_size" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf3_T_realloc_size">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_realloc_size">
			<xsl:attribute name="unite_T_realloc_size" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf4_T_calloc_size">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_calloc_size">
			<xsl:attribute name="unite_T_calloc_size" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf5_T_peak_size">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_peak_size">
			<xsl:attribute name="unite_T_peak_size" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf6_T_cpu_time">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_cpu_time">
			<xsl:attribute name="unite_T_cpu_time" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf7_T_total_fraction">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_total_fraction">
			<xsl:attribute name="unite_T_total_fraction" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="tbf:tbf8_T_caller_fraction">
		<xsl:param name="input" select="()"/>
		<xsl:for-each select="$input/@unite_T_caller_fraction">
			<xsl:attribute name="unite_T_caller_fraction" select="fn:string(.)"/>
		</xsl:for-each>
		<xsl:sequence select="fn:string($input)"/>
	</xsl:template>
	<xsl:template name="user:SumOfCpuTimeFromLabel">
		<xsl:param name="label" select="()"/>
		<xsl:param name="function" select="()"/>
		<xsl:variable name="var9_function" as="node()*" select="$function/ns1:function"/>
		<xsl:variable name="var8_resultof_filter" as="node()*" select="($function/ns1:name)[($label = fn:string(.))]"/>
		<T_time_profile xmlns="http://chercheurs.edf.com/logiciels/ProfileDB">
			<ProfileDB:function xmlns:ProfileDB="http://chercheurs.edf.com/logiciels/ProfileDB">
				<xsl:variable name="var3_let" as="xs:float*">
					<xsl:for-each select="($var8_resultof_filter)[fn:exists($function/ns1:cpu_time)]">
						<xsl:variable name="var1_cur_of_cpu_time" as="xs:float*">
							<xsl:for-each select="$function/ns1:cpu_time">
								<xsl:sequence select="xs:float(fn:string(.))"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:sequence select="xs:float(fn:string-join(for $x in $var1_cur_of_cpu_time return xs:string($x), ' '))"/>
					</xsl:for-each>
					<xsl:for-each select="$var9_function">
						<xsl:variable name="var2_resultof_SumOfCpuTimeFromLabel" as="node()?">
							<xsl:call-template name="user:SumOfCpuTimeFromLabel">
								<xsl:with-param name="label" select="$label" as="xs:string"/>
								<xsl:with-param name="function" as="node()">
									<function xmlns="http://chercheurs.edf.com/logiciels/ProfileNS">
										<xsl:sequence select="(./@node(), ./node())"/>
									</function>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:for-each select="$var2_resultof_SumOfCpuTimeFromLabel/ProfileDB:function/ProfileDB:cpu_time">
							<xsl:sequence select="xs:float(fn:string(.))"/>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="var4_source_of_" as="xs:decimal*">
					<xsl:for-each select="$var3_let">
						<xsl:sequence select="xs:decimal(.)"/>
					</xsl:for-each>
				</xsl:variable>
				<ProfileDB:cpu_time>
					<xsl:sequence select="xs:float(fn:sum($var4_source_of_))"/>
				</ProfileDB:cpu_time>
				<xsl:variable name="var7_let" as="xs:integer*">
					<xsl:for-each select="($var8_resultof_filter)[fn:exists($function/ns1:calls)]">
						<xsl:variable name="var5_cur_of_calls" as="xs:integer*">
							<xsl:for-each select="$function/ns1:calls">
								<xsl:sequence select="xs:integer(fn:string(.))"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:sequence select="xs:integer(fn:string-join(for $x in $var5_cur_of_calls return xs:string($x), ' '))"/>
					</xsl:for-each>
					<xsl:for-each select="$var9_function">
						<xsl:variable name="var6_resultof_SumOfCpuTimeFromLabel" as="node()?">
							<xsl:call-template name="user:SumOfCpuTimeFromLabel">
								<xsl:with-param name="label" select="$label" as="xs:string"/>
								<xsl:with-param name="function" as="node()">
									<function xmlns="http://chercheurs.edf.com/logiciels/ProfileNS">
										<xsl:sequence select="(./@node(), ./node())"/>
									</function>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:for-each select="$var6_resultof_SumOfCpuTimeFromLabel/ProfileDB:function/ProfileDB:calls">
							<xsl:sequence select="xs:integer(fn:string(.))"/>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:variable>
				<ProfileDB:calls>
					<xsl:sequence select="xs:string(xs:integer(fn:sum($var7_let)))"/>
				</ProfileDB:calls>
			</ProfileDB:function>
		</T_time_profile>
	</xsl:template>
	<xsl:output method="xml" encoding="UTF-8" byte-order-mark="no" indent="yes"/>
	<xsl:param name="cata_profile3" as="xs:string" required="yes"/>
	<xsl:param name="label" as="xs:string" required="yes"/>
	<xsl:template match="/">
		<ProfileDB xmlns="http://chercheurs.edf.com/logiciels/ProfileDB">
			<xsl:attribute name="xsi:schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance" select="'http://chercheurs.edf.com/logiciels/ProfileDB file:///Z:/5C/V4/4Eric/cata_profile_DB_XSLT.xsd'"/>
			<xsl:for-each select="ns1:ProfileNS/ns1:Profile">
				<xsl:variable name="var14_cur" as="node()" select="."/>
				<Profile>
					<xsl:variable name="var1_run_id" as="node()" select="ns1:run_id"/>
					<profile>
						<sha1>
							<xsl:sequence select="fn:string($var1_run_id/ns1:sha1)"/>
						</sha1>
						<code_name>
							<xsl:sequence select="fn:string($var1_run_id/ns1:code_name)"/>
						</code_name>
						<test_name>
							<xsl:sequence select="fn:string($var1_run_id/ns1:test_name)"/>
						</test_name>
						<version>
							<xsl:sequence select="fn:string($var1_run_id/ns1:version)"/>
						</version>
						<timestamp>
							<xsl:sequence select="xs:string(xs:integer(fn:string($var1_run_id/ns1:timestamp)))"/>
						</timestamp>
						<build_type>
							<xsl:sequence select="fn:string($var1_run_id/ns1:build_type)"/>
						</build_type>
						<execution>
							<xsl:sequence select="fn:string($var1_run_id/ns1:execution)"/>
						</execution>
						<procs>
							<xsl:sequence select="xs:string(xs:integer(fn:string($var1_run_id/ns1:procs)))"/>
						</procs>
						<host>
							<xsl:sequence select="fn:string($var1_run_id/ns1:host)"/>
						</host>
						<OS>
							<xsl:sequence select="fn:string($var1_run_id/ns1:OS)"/>
						</OS>
						<xsl:for-each select="ns1:time_profile">
							<total_cpu_time>
								<xsl:call-template name="tbf:tbf1_T_total_cpu_time">
									<xsl:with-param name="input" select="ns1:total_cpu_time" as="node()"/>
								</xsl:call-template>
							</total_cpu_time>
						</xsl:for-each>
					</profile>
					<xsl:for-each select="fn:tokenize($label, fn:replace('@,@', '(\.|\$|\^|\{|\[|\(|\||\)|\*|\+|\?|\\)', '\\$1'))">
						<xsl:variable name="var8_cur" as="xs:string" select="."/>
						<xsl:variable name="var7_time_profile" as="node()?" select="$var14_cur/ns1:time_profile"/>
						<time_profile>
							<name>
								<xsl:sequence select="."/>
							</name>
							<xsl:for-each select="$var7_time_profile/ns1:function">
								<xsl:variable name="var2_resultof_SumOfCpuTimeFromLabel" as="node()?">
									<xsl:call-template name="user:SumOfCpuTimeFromLabel">
										<xsl:with-param name="label" select="$var8_cur" as="xs:string"/>
										<xsl:with-param name="function" as="node()">
											<function xmlns="http://chercheurs.edf.com/logiciels/ProfileNS">
												<xsl:sequence select="(./@node(), ./node())"/>
											</function>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:for-each select="$var2_resultof_SumOfCpuTimeFromLabel/ns0:function/ns0:cpu_time">
									<cpu_time>
										<xsl:sequence select="(./@node(), ./node())"/>
									</cpu_time>
								</xsl:for-each>
							</xsl:for-each>
							<xsl:for-each select="$var7_time_profile">
								<xsl:variable name="var5_cur" as="node()" select="."/>
								<xsl:for-each select="ns1:function">
									<xsl:variable name="var4_resultof_SumOfCpuTimeFromLabel" as="node()?">
										<xsl:call-template name="user:SumOfCpuTimeFromLabel">
											<xsl:with-param name="label" select="$var8_cur" as="xs:string"/>
											<xsl:with-param name="function" as="node()">
												<function xmlns="http://chercheurs.edf.com/logiciels/ProfileNS">
													<xsl:sequence select="(./@node(), ./node())"/>
												</function>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:for-each select="$var4_resultof_SumOfCpuTimeFromLabel/ns0:function">
										<xsl:variable name="var3_cur" as="node()" select="."/>
										<xsl:for-each select="ns0:cpu_time">
											<total_fraction>
												<xsl:for-each select="$var3_cur/ns0:total_fraction/@unite_T_total_fraction">
													<xsl:attribute name="unite_T_total_fraction" namespace="" select="fn:string(.)"/>
												</xsl:for-each>
												<xsl:sequence select="(xs:float(fn:string(.)) div xs:float(fn:string($var5_cur/ns1:total_cpu_time)))"/>
											</total_fraction>
										</xsl:for-each>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:for-each>
							<xsl:for-each select="$var7_time_profile/ns1:function">
								<xsl:variable name="var6_resultof_SumOfCpuTimeFromLabel" as="node()?">
									<xsl:call-template name="user:SumOfCpuTimeFromLabel">
										<xsl:with-param name="label" select="$var8_cur" as="xs:string"/>
										<xsl:with-param name="function" as="node()">
											<function xmlns="http://chercheurs.edf.com/logiciels/ProfileNS">
												<xsl:sequence select="(./@node(), ./node())"/>
											</function>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:for-each select="$var6_resultof_SumOfCpuTimeFromLabel/ns0:function/ns0:calls">
									<calls>
										<xsl:sequence select="xs:string(xs:integer(fn:string(.)))"/>
									</calls>
								</xsl:for-each>
							</xsl:for-each>
						</time_profile>
					</xsl:for-each>
					<xsl:for-each select="ns1:memory_profile">
						<xsl:variable name="var9_count" as="node()" select="ns1:count"/>
						<xsl:variable name="var10_allocation" as="node()" select="ns1:allocation"/>
						<memory_profile>
							<malloc>
								<xsl:sequence select="xs:string(xs:integer(fn:string($var9_count/ns1:malloc)))"/>
							</malloc>
							<calloc>
								<xsl:sequence select="xs:string(xs:integer(fn:string($var9_count/ns1:calloc)))"/>
							</calloc>
							<realloc>
								<xsl:sequence select="xs:string(xs:integer(fn:string($var9_count/ns1:realloc)))"/>
							</realloc>
							<free>
								<xsl:sequence select="xs:string(xs:integer(fn:string($var9_count/ns1:free)))"/>
							</free>
							<malloc_size>
								<xsl:call-template name="tbf:tbf2_T_malloc_size">
									<xsl:with-param name="input" select="$var10_allocation/ns1:malloc_size" as="node()"/>
								</xsl:call-template>
							</malloc_size>
							<realloc_size>
								<xsl:call-template name="tbf:tbf3_T_realloc_size">
									<xsl:with-param name="input" select="$var10_allocation/ns1:realloc_size" as="node()"/>
								</xsl:call-template>
							</realloc_size>
							<calloc_size>
								<xsl:call-template name="tbf:tbf4_T_calloc_size">
									<xsl:with-param name="input" select="$var10_allocation/ns1:calloc_size" as="node()"/>
								</xsl:call-template>
							</calloc_size>
							<peak_size>
								<xsl:call-template name="tbf:tbf5_T_peak_size">
									<xsl:with-param name="input" select="$var10_allocation/ns1:peak_size" as="node()"/>
								</xsl:call-template>
							</peak_size>
						</memory_profile>
					</xsl:for-each>
					<xsl:for-each select="fn:doc($cata_profile3)/ns1:ProfileNS/ns1:Profile">
						<raw_profile>
							<raw_profile_xml>
								<xsl:call-template name="tbf:raw_copy"><xsl:with-param name="input" select="ns1:*"/></xsl:call-template>
							</raw_profile_xml>
						</raw_profile>
					</xsl:for-each>
				</Profile>
			</xsl:for-each>
		</ProfileDB>
	</xsl:template>
</xsl:stylesheet>
