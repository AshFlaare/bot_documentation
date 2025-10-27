!element SupportBot {
    webapp = container "Веб приложение" {
    }
    database = container "База данных" {
    }
}
# Можно добавить связи
webapp -> database "save" "API" "ASIS"
ApplicantUser ->  webapp "save" "API" "ASIS