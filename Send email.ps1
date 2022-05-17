$Outlook = New-Object -ComObject Outlook.Application


#צירך לבדוק שהמיילים תקינים - המייל הראשון מבוסס על ההנחה שהמייל הוא השם משתמש בלי קידומת דהיינו השתי אותיות הראשונות
# $MAIL.TO ולהזין ידנית המייל המבוקש במשתנה $EMAIL אם לא, אפשר להוריד את המשתנה 
$user = $env:Username 

$email = $user.Substring(2) + "@moin.gov.il"

$Mail = $Outlook.CreateItem(0)

$Mail.To = $email

#כאן תרשום מייל חיצוני
$Mail.CC = "jl8439246@gmail.com"

$Mail.Subject = "subject"

$Mail.Body = "testing"

$Mail.Send()