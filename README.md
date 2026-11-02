# Coleta e visualização de localizações

Aplicativo Flutter desenvolvido para a atividade de **Desenvolvimento de Dispositivos Móveis**. O app coleta posições do aparelho, salva os registros localmente e permite consultar a lista e visualizar os pontos em um mapa.

## Funcionalidades

- Iniciar e parar a coleta de localização.
- Solicitar as permissões de localização e verificar se o serviço de localização do aparelho está ligado.
- No Android, manter uma notificação enquanto a coleta está ativa. A frequência solicitada ao sistema é de 20 segundos; o Android pode entregar posições em intervalos diferentes conforme as condições do aparelho.
- Salvar cada posição no banco SQLite local `localizacoes.db`.
- Consultar os 100 registros mais recentes, atualizar a lista e apagar o histórico mediante confirmação.
- Exibir os registros em um mapa OpenStreetMap, com marcadores e opção para atualizar ou enquadrar os pontos.
- Usar tema escuro por padrão, com opção de alternar entre tema escuro e claro.

Os registros armazenados têm identificador, latitude, longitude, precisão e instante da coleta em formato UTC. A tela de histórico apresenta o horário convertido para o fuso local do aparelho.

## Tecnologias e pacotes

- Flutter e Dart
- `geolocator` para permissões e posições
- `sqflite` e `path` para persistência local
- `flutter_map` e `latlong2` para o mapa
- `path_provider` para o diretório de cache dos mapas

## Organização do código

```text
lib/
├── app.dart
├── main.dart
├── theme/
└── features/localizacoes/
    ├── models/
    ├── data/
    │   ├── database/
    │   └── repositories/
    ├── services/
    └── presentation/
        ├── screens/
        └── widgets/
```

- `models`: modelo e conversão dos dados de localização.
- `data/database`: criação e abertura do banco SQLite.
- `data/repositories`: operações de inclusão, consulta e remoção.
- `services`: acesso à localização e configuração do cache do mapa.
- `presentation`: telas de coleta, histórico e mapa, além dos componentes visuais.
- `theme`: tema e controle da alternância entre claro e escuro.

## Executar no Android

### Requisitos

- Flutter instalado e configurado.
- Android SDK instalado, com as licenças aceitas e o NDK `28.2.13676358` disponível (versão solicitada pela configuração Android deste projeto).
- Celular Android com depuração USB habilitada ou um emulador.
- No Windows, o modo de desenvolvedor pode ser necessário para permitir os links simbólicos usados por plugins Flutter.

### Comandos

Na pasta do projeto, execute:

```bash
flutter pub get
flutter devices
flutter run -d <id-do-dispositivo>
```

Se houver apenas um dispositivo conectado, também é possível usar `flutter run`.

## Permissões e coleta

O manifesto Android declara permissões de localização aproximada, precisa e em segundo plano, além de acesso à internet para carregar o mapa. Ao iniciar a coleta, aceite a permissão de localização solicitada pelo sistema e mantenha o serviço de localização do aparelho ligado. Para obter uma primeira posição, o GPS pode precisar de algum tempo e de uma visão mais aberta do céu.

A coleta é solicitada explicitamente pelo usuário no app. A permissão de segundo plano declarada no manifesto, por si só, não substitui os requisitos e as autorizações que o Android pode exigir para uso contínuo em segundo plano.

## Banco de dados

O SQLite cria a tabela `localizacoes` com estas colunas:

| Coluna | Tipo | Uso |
| --- | --- | --- |
| `id` | `INTEGER` | Chave primária autoincremental |
| `latitude` | `REAL` | Latitude em graus |
| `longitude` | `REAL` | Longitude em graus |
| `precisao` | `REAL` | Precisão informada pelo sistema, em metros |
| `instante` | `TEXT` | Instante da posição em ISO 8601/UTC |

O histórico fica no armazenamento privado do aplicativo no aparelho. Desinstalar o app ou limpar seus dados pelo Android remove esse banco.

## Mapa

O mapa utiliza tiles do OpenStreetMap pela biblioteca `flutter_map` e mantém cache local limitado para apoiar a visualização. Ao distribuir ou publicar o aplicativo, confira os termos de uso e a política de uso dos servidores de tiles do OpenStreetMap e configure um identificador de pacote apropriado para o projeto.

## Plataformas

O banco `sqflite` e a configuração atual estão direcionados ao uso em Android. Executar no Chrome não oferece suporte ao banco SQLite nativo usado aqui e pode resultar em erro de inicialização do `databaseFactory`. Embora exista configuração de stream para plataformas Apple no serviço de localização, permissões e capacidades de execução em segundo plano do iOS ainda precisam ser configuradas separadamente antes de considerar essa plataforma pronta.

## Verificações de desenvolvimento

Para analisar o código e executar os testes do projeto:

```bash
flutter analyze
flutter test
```

Esses comandos estão documentados como verificações sugeridas; a inclusão deles aqui não significa que tenham sido executados nesta atualização.
