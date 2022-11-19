# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.  

____
####  Запросы к сервисам
![alt text](images/1_1.png)  
![alt text](images/1_2.png)  
![alt text](images/1_3.png)    
####  Запуск bash в подах
![alt text](images/1_4.png)  

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.  
####  Увеличение до 3х реплик
![alt text](images/1_5.png)  

####  Список нод на которых поднялись поды
![alt text](images/1_6.png)  
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---