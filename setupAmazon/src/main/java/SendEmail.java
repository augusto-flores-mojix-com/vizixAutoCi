import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;
import java.io.DataOutputStream;
import java.io.FileOutputStream;

public class SendEmail {

    public static String description=System.getProperty("DESCRIPTION");
    public static String to = System.getProperty("EMAILTO");
    public static String status=System.getProperty("STATUS");
    public static String filePath=System.getProperty("FILEPATH");
    public static String reportDetailPath=System.getProperty("REPORTDETAILPATH");
    public static String environmentInfo=System.getProperty("ENVIRONMNETINFO");
    public static String keyVersion=System.getProperty("KEYVERSION");
    public static String pathFile=System.getProperty("PATH_HISTORIC");
    public static boolean createHistoric=Boolean.parseBoolean(System.getProperty("CREATE_HISTORIC"));
    public static String user=System.getProperty("USER");
    public static String pwd=System.getProperty("PASSWORD");
    //public static String imagePath=System.getProperty("IMAGE_PATH");
    public static String emailType=System.getProperty("EMAIL_TYPE");

    /**
     * Main class to send email
     * @param args
     */
    public static void main(String[] args) {

        System.out.println("***************************************************");
        System.out.println("*                 Send Email                      *");
        System.out.println("***************************************************");
        System.out.println(" INFO > description : "+description);
        System.out.println(" INFO > to : "+to);
        System.out.println(" INFO > status : "+status);
        System.out.println(" INFO > filePath : "+filePath);
        System.out.println(" INFO > reportDetailPath : "+reportDetailPath);
        System.out.println(" INFO > environmentInfo : "+environmentInfo);
        System.out.println(" INFO > keyVersion : "+keyVersion);
        System.out.println(" INFO > pathFile : "+pathFile);
        System.out.println(" INFO > createHistoric "+ createHistoric);
        System.out.println(" INFO > emailType : "+emailType);

        String from = "Automation.Vizix.Amazon@mojix.com";

        Properties properties = System.getProperties();

        // Setup mail server
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");

        // Add historic summary value
        String historicSummary="";
        try(BufferedReader br = new BufferedReader(new FileReader(pathFile+keyVersion+".txt"))) {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                historicSummary = historicSummary + line + "<br>";
                line = br.readLine();
            }
        } catch (FileNotFoundException e) {
            System.out.println(" INFO > there is not register a previous result, it will be the first historic");
        } catch (IOException e) {
            e.printStackTrace();
        }

        String previousKeyVersion=historicSummary;

        String envValue="";
        // concat environment info
        try(BufferedReader br = new BufferedReader(new FileReader(environmentInfo))) {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                envValue = envValue + line + "<br>";
                line = br.readLine();
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Get the default Session object.
        Session session = Session.getDefaultInstance(properties,
                new Authenticator() {
                    protected PasswordAuthentication  getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                user ,pwd );
                    }
                });
        try{
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from,from));
            String[] result = to.split(";");
            for(String emailRec : result)
                message.addRecipient(Message.RecipientType.TO, new InternetAddress(emailRec));

            message.setSubject(String.format("Result : %s", status));
            Multipart multipart = new MimeMultipart();

            // Html Format
            BodyPart htmlBodyPart = new MimeBodyPart();
            String  Body = buildBody(filePath, envValue, reportDetailPath, previousKeyVersion,keyVersion,pathFile,createHistoric);

            htmlBodyPart.setContent(Body, "text/html; charset=utf-8" );
            multipart.addBodyPart(htmlBodyPart);

            // Embedded Image
//          MimeBodyPart imagePart = new MimeBodyPart();
//          imagePart.attachFile(imagePath);
//          imagePart.setContentID("<abc>");
//          imagePart.setDisposition(MimeBodyPart.INLINE);
//          multipart.addBodyPart(imagePart);

            message.setContent(multipart);
            Transport.send(message);
            System.out.println("INFO > Sent message successfully....");
        }catch (MessagingException mex) {
            System.out.print("ERROR > There was a problem when sending the email.... error : " +mex.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * This method is to build the html body to sent in the email body for cucumber
     * @param file
     * @param environment
     * @param link
     * @param previousKeyVersion
     * @param keyVersion
     * @param pathFile
     * @param createHistoric
     * @return
     * @throws IOException
     */
    private static String buildBody(String file, String environment, String link, String previousKeyVersion,String keyVersion,String pathFile,Boolean createHistoric) throws IOException {
        String css = "body {font-family: verdana,arial,sans-serif;	font-size:11px;	color:#333333;}table tr td, table tr th {font-size: 100%;                        }        table.details tr, th{            color: #ffffff; font-weight: bold;            text-align:center;            background:#2674a6;            white-space: nowrap;            font-size: 13px;        }        table.details tr,td{     color:#000000 ;       background:#eeeee0;            white-space: nowrap;            font-size: 12px;        }";
        String previousResult=!previousKeyVersion.isEmpty()?String.format("<b>[Previous]Summary Result:</b><br>This is the previous execution on the same branches<br> %s <br>",previousKeyVersion):previousKeyVersion;
        String table;
        switch (emailType){

            case "owasp" :
                table=BuildTableOwasp(file,keyVersion,pathFile,createHistoric);
                break;
            case "jmeter":
                table=BuildTableJmeter(file,keyVersion,pathFile,createHistoric);
                break;
            case "swarm":
                table=BuildTableSwarm(file,keyVersion,pathFile,createHistoric);
                break;
            default:
                table=buildTable(file,keyVersion,pathFile,createHistoric);
                break;
        }

        String bodyHtml = String.format("<html><head><style>%s</style></head><body>Hi Team <br><br><b>Environment Information:</b><br>%s<br>%s<b>[Actual]Summary Result :</b><br>This is the summary result of the test cases automated <br>%s<br><br>If you want to see the execution result please go to the link : <b><a href='%s'>Result - Report Detail</a></b>.<br><br>Regards<br>DevOps Team</body></html>", css, environment,previousResult ,table, link);
        return (bodyHtml);
    }

    /**
     * This method is to build a table on swarm
     * @return
     */
    private static String BuildTableSwarm(String file,String keyVersion,String pathFile,Boolean createHistoric)throws IOException {
        String table = "";
        BufferedReader br = new BufferedReader(new FileReader(file));
        try {
            // Read the file
            String line;
            StringBuilder sb = new StringBuilder();
            line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            if (createHistoric)
                writeFile(pathFile,table.replace("Summary Test Cases","Summary Test Cases (Previous Execution)"),keyVersion,".txt");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            br.close();
            return table;
        }
    }


    /**
     * this method is to get the summary table to display in the email.
     * @param file
     * @param keyVersion
     * @param pathFile
     * @param createHistoric
     * @return
     * @throws IOException
     */
    private static String BuildTableOwasp(String file,String keyVersion,String pathFile,Boolean createHistoric) throws IOException {
        String table = "";
        BufferedReader br = new BufferedReader(new FileReader(file));
        try {
            // Read the file
            String line;
            StringBuilder sb = new StringBuilder();
            line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                System.out.println("\n TEST : "+line+ "\n");
                if (line.contains("<table")) {
                    table=line;
                    break;
                }
                line = br.readLine();
            }
            if (createHistoric)
                writeFile(pathFile,table.replace("Summary Test Cases","Summary Test Cases (Previous Execution)"),keyVersion,".txt");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            br.close();
            return table;
        }
    }

    /**
     * need path for jmeter report generated by ant to get the summary and attach in the email.
     * @param file
     * @param keyVersion
     * @param pathFile
     * @param createHistoric
     * @return
     * @throws IOException
     */
    private static String BuildTableJmeter(String file,String keyVersion,String pathFile,Boolean createHistoric) throws IOException {
        String table = "";
        BufferedReader br = new BufferedReader(new FileReader(file));
        try {
            Boolean istablesummary = false;
            // Read the file
            String line;
            StringBuilder sb = new StringBuilder();
            line = br.readLine();
            boolean isSummary=false;
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());

                if (line.contains("Summary"))
                    isSummary=true;
                if (line.contains("<table") && isSummary) {
                    istablesummary = true;
                } else if (line.contains("</table>") && isSummary)
                {
                    table=table+line;
                    break;
                }
                table = istablesummary? table + line: table;
                table=table.replace("95%","50%");
                line = br.readLine();
            }
            if (createHistoric)
                writeFile(pathFile,table,keyVersion,".txt");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            br.close();
            return table;
        }
    }
    /**
     * This method is to parse the cucumber html report and get the summary for cucumber report
     * @param file
     * @param keyVersion
     * @param pathFile
     * @param createHistoric
     * @return
     * @throws IOException
     */
    private static String buildTable(String file,String keyVersion,String pathFile,Boolean createHistoric) throws IOException {
        String table = "";
        BufferedReader br = new BufferedReader(new FileReader(file));
        try {

            Boolean istablesummary = false;
            // Read the file
            String line;
            StringBuilder sb = new StringBuilder();
            line = br.readLine();
            int count=0;
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                if (line.contains("<tfoot")) {
                    istablesummary = true;
                } else if (line.contains("</tfoot>"))
                {
                    istablesummary = false;
                }

                String getNumbers = line.replaceAll("\\D+","");
                if (istablesummary){count++;}
                String th = count==5|| count==11 ? "<td align='center'><b><font color=green>%s</font></b></td>" :
                        count==6|| count==12 ? "<td align='center'><b><font color=red>%s</font></b></td>" :
                                "";
                line = th.isEmpty() ? line : String.format(th, getNumbers);
                table = istablesummary && !line.isEmpty() && count>10 && count<=15? table + line : table;
                line = br.readLine();
            }
            String logo=" <br> <img width=20% height=20% src='cid:abc'/>";
            table = "<table><tr><th colspan='4'>["+description+"] Summary Test Cases</th></tr><tr><th>Passed</th><th>Failed</th><th>Total</th><th>Time ms</th></tr><tr>" + table + "</tr></table>"+logo;
            if (createHistoric)
                writeFile(pathFile,table.replace("Summary Test Cases","Summary Test Cases (Previous Execution)"),keyVersion,".txt");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            br.close();
            return table;
        }
    }

    /**
     * This method is to create a file with the summary result to attached as historic
     * @param path
     * @param fileContent
     * @param filename
     * @param extention
     */
    private static void writeFile(String path,String fileContent, String filename,String extention) {
        try {
            DataOutputStream output = new DataOutputStream(new FileOutputStream(path+filename+extention));
            output.writeBytes(fileContent);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}