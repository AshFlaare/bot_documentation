workspace {
    name "Support Bot System" 
    description "Система бота для сбора обратной связи в системе «Умный Гараж»"
    
    model {
        applicant = person "Заявитель" "Механик или сервисный консультант. Оставляет обращения через бота, присоединяется к проблемам, получает решения"
        
        support = person "Сотрудник техподдержки" "Работник ТП. Принимает и закрывает обращения, пишет решения"

        messenger = softwareSystem "Мессенджер" "Платформа мессенджера (Telegram, VK, ...). Предоставляет API для ботов"
        
        supportBot = softwareSystem "Бот техподдержки" "Бот, с которым взаимодействуют пользователи через мессенджер"

        supportSystem = softwareSystem "Система обратной связи" "Система для хранения и обработки обращений. Аналитика, метрики, workflow" {
            
            connectorMessengers = container "Коннектор для мессенджеров" "Обрабатывает сообщения, поступающие из мессенджеров, и преобразует их в стандартный формат" 
            
            businessModule = container "Бизнес-логика системы поддержки" "Обрабатывает обращения, применяет правила маршрутизации и workflow"  {
                routing = component "Слой маршрутизации" "Принимает REST-запросы, определяет маршрут, вызывает нужное действие"
                middleware = component "Слой middleware" "Обрабатывает запросы до попадания в actions: логирование, аутентификация, валидация, CORS и т.п."
                actions = component "Слой actions" "Реализует конкретное поведение для маршрутов (бизнес-операции)"
                service = component "Слой service" "Инкапсулирует бизнес-правила и взаимодействие между сущностями"
                orm = component "Слой доступа к данным" "Отвечает за работу с базой данных DynamoDB"
            }

            stateMachineModule  = container "Конечный автомат" "Управляет состояниями диалога с пользователем в процессе создания и обработки обращения" 

            database = container "База данных" "Хранит обращения, пользователей, статусы и аналитические данные" "DynamoDB" {
                tags "Database"
            }
        }

        support -> messenger "Управляет обращениями" "Сообщения"
        applicant -> messenger "Создает и отслеживает обращения" "Сообщения"

        messenger -> supportBot "Передает события" "Bot API"
        supportBot -> supportSystem "Передает стандартизированные события" "REST API"

        supportBot -> connectorMessengers "Передает стандартизированные события" "REST API"
        connectorMessengers -> businessModule "Передает события" "JSON через HTTP"
        businessModule -> stateMachineModule "Запрашивает переходы состояний" "Вызовы API автомата"
        businessModule -> database "Сохраняет и извлекает данные" "DynamoDB SDK"

        connectorMessengers -> routing "Передает стандартизированные события" "REST API"
        routing -> middleware "Передает HTTP-запрос для предварительной обработки" "Express pipeline"
        middleware -> actions "Передает очищенный и проверенный запрос" "Express handler"
        actions -> service "Вызывает бизнес-логику обработки обращения" "Функциональный вызов"
        service -> orm "Запрашивает и сохраняет данные" "DynamoDB SDK"
        service -> stateMachineModule "Изменяет состояние обращения" "Вызов API автомата"
        orm -> database "Выполняет операции чтения/записи" "DynamoDB API"
    }


    views {
        systemContext supportSystem {
            title "Системный контекст"
            include applicant support messenger supportBot supportSystem
            autoLayout lr
        }

        container supportSystem {
            title "Контейнеры"
            include applicant support messenger supportBot connectorMessengers businessModule stateMachineModule database
            autoLayout lr
        }

        component businessModule {
            title "Компоненты бизнес-логики"
            include connectorMessengers businessModule routing middleware actions service orm database stateMachineModule
            autoLayout lr
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
            }
            element "Component" {
                background #566676
                color #ffffff
            }
            element "Container" {
                shape RoundedBox
            }
            element "Database" {
                shape Cylinder
                background #708090
                color #ffffff
            }
        }
    }
}
