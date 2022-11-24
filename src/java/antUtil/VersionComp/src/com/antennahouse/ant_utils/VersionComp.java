package com.antennahouse.ant_utils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.Project;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class VersionComp extends Task{
	private String src=null;
	private String dst=null;
	private String operator=null;
	private String result=null;
	private String delim=null;
	private static final List<String> operatorArray = Arrays.asList("lt","le","gt","ge","eq");
	private static final String snapShot = "-SNAPSHOT";
	
	/**
	 * Parameter get/set methods.
	 * @return
	 */
	public String getSrc(){
		return this.src;
	}
	public void setSrc(String src){
		this.src=src;
	}
	public String getDst(){
		return this.dst;
	}
	public void setDst(String dst){
		this.dst=dst;
	}
	public String getOperator(){
		return this.operator;
	}
	public void setOperator(String operator){
		this.operator=operator;
	}
	public String getDelim(){
		return this.delim;
	}
	public void setDelim(String delim){
		this.delim=delim;
	}
	public String getResult(){
		return this.result;
	}
	public void setResult(String result){
		this.result=result;
	}
	/**
	 * Validate parameter
	 * @throws BuildException
	 */
	protected void validateAttribute() throws BuildException{
		// null checking
		if (this.src == null) {
			throw new BuildException("Parameter 'src' is empty."); 
		}
		if (this.dst == null) {
			throw new BuildException("Parameter 'dst' is empty."); 
		}
		if (this.operator == null) {
			throw new BuildException("Parameter 'operator' is empty."); 
		}
		if (this.result == null) {
			throw new BuildException("Parameter 'result' is empty."); 
		}
		if (this.delim == null) {
			throw new BuildException("Parameter 'delim' is empty."); 
		}
		// delimiter checking
		if (this.delim.length() != 1) {
			throw new BuildException("Parameter 'delim' is not single character. delim='" + this.delim + "'");
		}
		if (!StringPattern.isAllBasicLatin(this.delim) || StringPattern.isDigit(this.delim)) {
			throw new BuildException("Parameter 'delim' is not in Basic Latin character without digit. delim='" + this.delim + "'");
		}
		if (!checkVersionFormat(this.src, this.delim)) {
			throw new BuildException("Parameter 'src' contains non digit version string. src='" + this.src + "'");
		}
		if (!checkVersionFormat(this.dst, this.delim)) {
			throw new BuildException("Parameter 'dst' contains non digit version string. dst='" + this.dst + "'");
		}
		// Operator check
		if (operatorArray.indexOf(this.operator) == -1) {
			throw new BuildException("Parameter 'operator' is invalid. operator='" + this.operator + "'");
		}
		// Result check
		if (this.result.trim() == "") {
			throw new BuildException("Parameter 'result' is empty. result='" + this.result + "'");
		}
	}
	/**
	 * Check version format
	 */
	protected boolean checkVersionFormat(String versionStr, String delim){
		String regx = null;
		if (StringPattern.isRegExMetaChars(delim)){
			regx="[\\" + delim + "]";
		}else{
			regx=delim;
		}
		String[] versionArray=versionStr.split(regx);
		ArrayList<String> versionList = new ArrayList<String>(Arrays.asList(versionArray));
		List<String> versionListFiltered = versionList.stream().map(v -> filterSnapShot(v)).collect(Collectors.toList());
		for (String version:versionListFiltered) {
			if (!StringPattern.isDigit(version)) {
				return false;
			}
		}
		return true;
	}
	/**
	 * Remove "-SNAPSHOT" from version
	 * @param version
	 * @return 
	 */
	protected String filterSnapShot(String version) {
		if (version.endsWith(snapShot)) {
			int endPos = version.length() - snapShot.length();
			return version.substring(0, endPos);
		}else {
			return version;
		}
	}
	/**
	 * Get version as ArrayList<Integer>
	 * @param versionStr
	 * @param delim
	 * @return
	 */
	protected ArrayList<Integer> getVersions(String versionStr, String delim) {
		String regx = null;
		if (StringPattern.isRegExMetaChars(delim)){
			regx="[\\" + delim + "]";
		}else{
			regx=delim;
		}
		String[] versions=versionStr.split(regx);
		ArrayList<String> versionList = new ArrayList<String>(Arrays.asList(versions));
		List<String> versionListFiltered = versionList.stream().map(v -> filterSnapShot(v)).collect(Collectors.toList());
		List<Integer> intVersionList = versionListFiltered.stream().map(v -> Integer.valueOf(v)).collect(Collectors.toList()); 
		ArrayList<Integer> intVersionArrayList = new ArrayList<Integer>(intVersionList);
		return intVersionArrayList;
	}
	/**
	 * Padding zero to ArrayList<Integer>
	 * @param versionList
	 * @param count
	 * @return ArrayList<Integer>
	 */
	protected ArrayList<Integer> addZeroToTail(ArrayList<Integer> versionList, int count){
		Integer padding[] = new Integer[count];
		Arrays.fill(padding,0);
		ArrayList<Integer> paddingList = new ArrayList<Integer>(Arrays.asList(padding));
		versionList.addAll(paddingList);
		return versionList;
	}
	/**
	 * Get version difference
	 * @param srcVersionList
	 * @param dstVersionList
	 * @param size
	 * @return
	 */
	protected ArrayList<Integer> getDiff(ArrayList<Integer> srcVersionList, ArrayList<Integer> dstVersionList, int size){
		List<Integer> diffList = IntStream.range(0, size)
				                          .map(i -> (srcVersionList.get(i) - dstVersionList.get(i)))
				                          .map(diff -> genDiff(diff))
				                          .boxed()
				                          .collect(Collectors.toList());
		ArrayList<Integer> diffArrayList = new ArrayList<Integer>(diffList);
		return diffArrayList;
	}
	/**
	 * Simplify version difference
	 * @param diff
	 * @return
	 */
	protected int genDiff(int diff) {
		if (diff > 0) {
			return 1;
		}else if (diff < 0) {
			return -1;
		}else {
			return 0;
		}
	}
	
	/**
	 * Do comparison
	 * @throws BuildException
	 */
	public void execute() throws BuildException {
		validateAttribute();
		ArrayList<Integer> srcVersionList = getVersions(this.src, this.delim);
		ArrayList<Integer> dstVersionList = getVersions(this.dst, this.delim);
		System.out.println("src=" + srcVersionList.toString());
		System.out.println("dst=" + dstVersionList.toString());
		System.out.println("operator='" + this.operator + "'");
		int srcVersionSize = srcVersionList.size();
		int dstVersionSize = dstVersionList.size();
		int diff = srcVersionSize - dstVersionSize;
		if (diff > 0) {
			dstVersionList = addZeroToTail(dstVersionList, diff);
		}else if (diff < 0) {
			srcVersionList = addZeroToTail(dstVersionList, -1 * diff);
		}
		int size = srcVersionList.size();
		ArrayList<Integer> diffVersionList = getDiff(srcVersionList, dstVersionList, size);
	    log("diffVersionList=" + diffVersionList.toString(), Project.MSG_VERBOSE);
		int gtIndex = diffVersionList.indexOf(1);
		int ltIndex = diffVersionList.indexOf(-1);
		String compareResult=null;
		if (gtIndex < ltIndex && gtIndex != -1) {
			compareResult = "gt";
		}else if (gtIndex > ltIndex && ltIndex != -1) {
			compareResult = "lt";
		}else {
			compareResult = "eq";
		}
		boolean finalResult; 
		if (compareResult.equals(this.operator)) {
			finalResult = true;
		}else if (compareResult.equals("eq") && (operator.equals("ge") || operator.equals("le"))) {
			finalResult = true;
		}else if (compareResult.equals("lt") && (operator.equals("lt") || operator.equals("le"))) {
			finalResult = true;
		}else if (compareResult.equals("gt") && (operator.equals("gt") || operator.equals("ge"))) {
			finalResult = true;
		}else {
			finalResult = false;
		}
		System.out.println("result=" + Boolean.valueOf(finalResult).toString());
		Project project = getProject();
		String property = Boolean.valueOf(finalResult).toString();
		project.setProperty(this.result, property);
	    log("Set property: " + this.result + " -> " + property, Project.MSG_VERBOSE);
	}

}
