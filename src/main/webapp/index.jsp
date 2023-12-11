<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="com.amazonaws.*" %>
<%@ page import="com.amazonaws.auth.*" %>
<%@ page import="com.amazonaws.auth.profile.*" %>
<%@ page import="com.amazonaws.services.ec2.*" %>
<%@ page import="com.amazonaws.services.ec2.model.*" %>
<%@ page import="com.amazonaws.services.s3.*" %>
<%@ page import="com.amazonaws.services.s3.model.*" %>
<%@ page import="com.amazonaws.services.dynamodbv2.*" %>
<%@ page import="com.amazonaws.services.dynamodbv2.model.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<%! 
	private AmazonS3           s3;		
 %>
<%
   if (request.getMethod().equals("HEAD")) return;
%>

<%
    if (s3 == null) {
    	AWSCredentials credentials = new ProfileCredentialsProvider("default").getCredentials();
    	//com.amazonaws.regions.Region region = com.amazonaws.regions.Region.getRegion(com.amazonaws.regions.Regions.US_WEST_2);

        s3     = new AmazonS3Client(credentials);
    }	
%>


<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>Hello AWS Web World!</title>
    <link rel="stylesheet" href="styles/styles.css" type="text/css" media="screen">
</head>
<body>
	<div id="content" class="container">
        <div class="section grid grid5 s3">
		<form action="" method="get">
			<input type="file" accept=".jpg,.jpeg,.png,.tiff" name="iu" />
			<input type="submit" value="Upload" />
			<input type="submit" Value="Delete Object" name="db" />
			<input type="submit" Value="Download" name="downb" />
		    <%
				createBucket("beccse2021");
				String filePath=request.getParameter("iu");
				if(filePath!=null && filePath!="")
					uploadImage("beccse2021",filePath,out);
				out.print("<Table border='1'><tr>");
				displayImages("beccse2021",out);
				if(request.getParameter("db")!=null && request.getParameter("iselect")!=null){
					deleteImage("beccse2021",request.getParameter("iselect"));
					response.sendRedirect("index.jsp");
				}
				if(request.getParameter("downb")!=null && request.getParameter("iselect")!=null){
					downloadImage("beccse2021",request.getParameter("iselect"));
				}
			%>
		</form>
        </div>
    </div>
</body>
</html>
<%!
void createBucket(String bucketName)throws Exception{
	if(!s3.doesBucketExist(bucketName)){
		s3.createBucket(bucketName);
	}
}
void uploadImage(String bucketName, String filePath, javax.servlet.jsp.JspWriter myOut) throws Exception{
	File f=null;
	try{
		f = new File(filePath);
		PutObjectRequest req = 
				new PutObjectRequest(bucketName,f.getName(),f);
		s3.putObject(req);
		s3.setObjectAcl(bucketName, f.getName(), CannedAccessControlList.PublicRead);
	}
	catch(Exception e){
		myOut.print("Exception Occured. File Upload Failed");
	}
}
void displayImages(String bucketName, javax.servlet.jsp.JspWriter myOut) throws Exception{
	int count=0;
	ObjectListing res = s3.listObjects("beccse2021");
	List<S3ObjectSummary> objs = res.getObjectSummaries();
	for(S3ObjectSummary obj : objs){
		if(count!=1 && count%4==1)
			myOut.print("</tr><tr>");
		String objkey=obj.getKey();
		if(objkey.contains(".jpg")||objkey.contains(".png")||objkey.contains(".jpeg")||objkey.contains(".tiff")){
			String objurl="https://beccse2021.s3-us-west-2.amazonaws.com/"+objkey;
			myOut.print("<td><input type='radio' name='iselect' value='"+objkey+"' /></td>");
			myOut.print("<td><img alt='Image' height='100px' width='100px' src='"+objurl+"'/></td>");
			count++;
		}
	}
}
void deleteImage(String bucketName, String objectKey){
	s3.deleteObject(bucketName, objectKey);
}
void downloadImage(String bucketName, String objectKey){
	try{
		S3Object o=s3.getObject(bucketName, objectKey);
		S3ObjectInputStream s3is = o.getObjectContent();
		FileOutputStream fos = new FileOutputStream(new File("D:/test/"+objectKey));
		byte[] read_buf=new byte[1024];
		int read_len=0;
		while((read_len = s3is.read(read_buf))>0)
			fos.write(read_buf,0,read_len);
		s3is.close();
		fos.close();
	}catch(Exception e){}
}
%>