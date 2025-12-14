workspace {
    name "Support Bot System" 
    description "Система бота для сбора обратной связи в системе «Умный Гараж»"
    
    model {
        applicant = person "Заявитель" "Механик или сервисный консультант. Оставляет обращения через бота, присоединяется к проблемам, получает решения"
        
        support = person "Сотрудник техподдержки" "Работник ТП. Принимает и закрывает обращения, пишет решения"

        tg = softwareSystem "Телеграм" "Cервис обмена сообщениями. Предоставляет интерфейс пользователям и API для ботов" {
            tags "Messenger"
        }
        vk = softwareSystem "Вконтакте" "Cервис обмена сообщениями. Предоставляет интерфейс пользователям и API для ботов" {
            tags "Messenger"
        }
        
        supportBotTg = softwareSystem "Бот техподдержки телеграма" "Бот, с которым взаимодействуют пользователи через мессенджер"

        supportBotVk = softwareSystem "Бот техподдержки вконтакте" "Бот, с которым взаимодействуют пользователи через мессенджер"

        supportSystem = softwareSystem "Система обратной связи" "Система для хранения и обработки обращений" {
            
            connectorMessengers = container "Коннектор для мессенджеров" "Обрабатывает сообщения, поступающие из мессенджеров, и преобразует их в стандартный формат" "JavaScript" LargeFontSmaller
            
            businessModule = container "Сервисная логика системы поддержки" "Обрабатывает обращения, применяет правила маршрутизации и workflow"  {
                routing = component "Слой маршрутизации" "Принимает REST-запросы, определяет маршрут, вызывает нужное действие" "Express" LargeFont
                middleware = component "Слой middleware" "Обрабатывает запросы до попадания в actions: логирование, аутентификация, валидация, CORS и т.п." "Express" LargeFont
                actions = component "Слой actions" "Реализует конкретное поведение для маршрутов (бизнес-операции)" "Express" LargeFont
                // service = component "Слой service" "Инкапсулирует бизнес-правила и взаимодействие между сущностями"
                stateMachineModule  = component "Конечный автомат" "Управляет состояниями диалога с пользователем в процессе создания и обработки обращения" "XState" LargeFont
                
            } 

            database = container "База данных" "Хранит обращения, пользователей, статусы и аналитические данные" "DynamoDB" {
                tags "Database", "LargeFont"
            }
        }

        support -> tg "Управляет обращениями" "Сообщения"
        applicant -> tg "Создает, присоединяется к обращениям и отслеживает их" "Сообщения"
        applicant -> vk "Создает, присоединяется к обращениям и отслеживает их" "Сообщения"


        tg -> supportSystem "Передает события" "Bot API"
        vk -> supportSystem "Передает события" "Bot API"
        supportBotTg -> supportSystem "Передает стандартизированные события" "REST API"
        supportBotVk -> supportSystem "Передает стандартизированные события" "REST API"

        supportBotTg -> connectorMessengers "Передает стандартизированные события" "REST API"
        supportBotVk -> connectorMessengers "Передает стандартизированные события" "REST API"
        connectorMessengers -> businessModule "Передает события" "JSON через HTTP"
        businessModule -> database "Сохраняет и извлекает данные" "DynamoDB SDK"

        stateMachineModule -> database "Сохраняет и извлекает данные" "DynamoDB SDK"
        middleware -> database "Сохраняет и извлекает состояния диалогов" "DynamoDB SDK"
        stateMachineModule -> connectorMessengers "Возвращает ответы для пользователей" "REST API"

        connectorMessengers -> routing "Передает стандартизированные события" "REST API"
        routing -> middleware "Передает HTTP-запрос для предварительной обработки" "Express pipeline"
        middleware -> actions "Передает очищенный и проверенный запрос" "Express handler"
        actions -> stateMachineModule "Возвращает измененное состояние" "Вызов API автомата"
        stateMachineModule -> actions "Изменяет состояние обращения" "Функциональный вызов"
        // actions -> service "Вызывает бизнес-логику обработки обращения" "Функциональный вызов"
        // service -> stateMachineModule "Изменяет состояние обращения" "Вызов API автомата"

        // service -> actions "Возвращает результат бизнес-операции" "Response Data"
        actions -> middleware "Возвращает обработанный ответ" "HTTP Response"
        middleware -> routing "Возвращает финальный ответ" "HTTP Response"
        routing -> connectorMessengers "Возвращает ответ для отправки в мессенджер" "REST Response"
    }

    views {
        systemContext supportSystem {
            title "Системный контекст"
            include applicant support tg vk supportSystem
            autoLayout lr
        }

        container supportSystem {
            title "Контейнеры"
            include supportBotTg supportBotVk connectorMessengers businessModule database
            include supportBotTg->connectorMessengers
            include supportBotVk->connectorMessengers
            include connectorMessengers->businessModule
            include businessModule->database
            exclude businessModule->connectorMessengers
            
            autoLayout lr
        }

        component businessModule {
            title "Компоненты сервисной логики системы поддержки"
            include connectorMessengers routing middleware actions stateMachineModule database
            //autoLayout lr
        }
        
        styles {
            element "Person" {
                background #08427b
                color #ffffff
                shape Person
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            relationship "Relationship" {
                color #1C062D
                dashed false
            }
            element "Container" {
                background #385878
                color #ffffff
                width 500
                height 350
            }
            element "Component" {
                background #566676
                color #ffffff
                width 500
                height 350
            }
            element "Container" {
                shape RoundedBox
            }
            element "Database" {
                shape Cylinder
                background #708090
                color #ffffff
            }
            element "Messenger" {
                background #847B9C
                color #ffffff
            }
            element "LargeFont" {
                fontSize 35
            }
            element "LargeFontSmaller" {
                fontSize 32
            }
            element "LargeTechnology" {
                fontSize 28
            }
            element "technology" {
                fontSize 36
            }
        }
    }
}
