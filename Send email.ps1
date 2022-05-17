$Outlook = New-Object -ComObject Outlook.Application


#צירך לבדוק שהמיילים תקינים - המייל הראשון מבוסס על ההנחה שהמייל הוא השם משתמש בלי קידומת דהיינו השתי אותיות הראשונות
# $MAIL.TO ולהזין ידנית המייל המבוקש במשתנה $EMAIL אם לא, אפשר להוריד את המשתנה 
$user = $env:Username 
#deletes first 2 letters from Username and adds domain to it
$email = $user.Substring(2) + "@domain.co.il"
#Creates New email
$Mail = $Outlook.CreateItem(0)
#sends mail to email address form $email variable
$Mail.To = $email

#כאן תרשום מייל חיצוני
$Mail.CC = "<make sure email is in quotations>"
#sets subject of email
$Mail.Subject = "subject"
#sets body of email
$Mail.Body = "testing"
#sends email
$Mail.Send()
