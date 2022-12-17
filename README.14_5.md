# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```
kubectl apply -f 14.5/example-security-context.yml
```   

![alt text](images/14_5_1.jpg) 

Проверьте установленные настройки внутри контейнера

```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```
![alt text](images/14_5_2.jpg) 
## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру
и ко второму контейнеру. Для второго модуля разрешите связь только с
первым контейнером. Проверьте корректность настроек.

---  
### Запущенные поды
![alt text](images/14_5_3.jpg) 
### Запрос внутри контейнера nginx где разрешен трафик до интернета и nginx2
![alt text](images/14_5_4.jpg) 

### Запрос внутри контейнера nginx2
![alt text](images/14_5_5.jpg) 

### Ссылка на манифесты
[nginx](manifests/nginx.yaml)   
[nginx2](manifests/nginx2.yaml)   
[nginx-service](manifests/nginx-service.yaml)   
[nginx-service2](manifests/nginx-service2.yaml)   
[ntwpo](manifests/ntwpo.yaml)   
[ntwpo2](manifests/ntwpo2.yaml)   
### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---