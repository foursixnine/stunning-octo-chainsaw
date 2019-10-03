import mailbox
import re
import email.errors

list_names = ('python-list', 'python-dev', 'python-bugs')

emails = {}
inbox = mailbox.Maildir('~/Maildir', factory=None)

for key in inbox.iterkeys():
    try:
        message = inbox[key]
    except email.errors.MessageParseError:
        continue                # The message is malformed. Just leave it.
    try:

        email = re.findall('\S+@\S+',message['From'])[0].lower()
        emails[email] = emails.get(email, 0) + 1
    except IndexError:
        print ("what")
        email = message['From'].lower()
        emails[email] = emails.get(email, 0) + 1
        continue

for mail,count in emails.items():
    print ("%d %s" % (count,mail))

