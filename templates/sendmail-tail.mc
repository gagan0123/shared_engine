dnl # Masquerading options
FEATURE(`always_add_domain')dnl
MASQUERADE_AS(`example.com')dnl
FEATURE(`allmasquerade')dnl
FEATURE(`masquerade_envelope')dnl
dnl # Default Mailer setup
MAILER_DEFINITIONS
MAILER(`local')dnl
MAILER(`smtp')dnl
INPUT_MAIL_FILTER(`opendkim', `S=inet:8891@localhost')dnl
define(`MAIL_HUB', `example.com.')dnl
define(`LOCAL_RELAY', `example.com.')dnl