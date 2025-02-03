from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, email, first_name, last_name, password=None, role="eleve"):
        if not email:
            raise ValueError("L'utilisateur doit avoir une adresse email")

        email = self.normalize_email(email)
        user = self.model(email=email, first_name=first_name, last_name=last_name, role=role)
        user.set_password(password)  # Hash du mot de passe
        user.save(using=self._db)
        return user

    def create_superuser(self, email, first_name, last_name, password):
        user = self.create_user(email, first_name, last_name, password, role="admin")
        user.is_admin = True
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user

class User(AbstractBaseUser, PermissionsMixin):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    role = models.CharField(max_length=50, choices=[
        ('eleve', 'Élève'),
        ('parent', 'Parent'),
        ('enseignant', 'Enseignant'),
        ('admin', 'Administrateur'),
    ])
    created_at = models.DateTimeField(auto_now_add=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = UserManager()

    def __str__(self):
        return self.email


class Course(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    subject = models.CharField(max_length=255)
    media_type = models.CharField(max_length=50)
    progress = models.FloatField(default=0.0)  # ✅ Ajoute ce champ avec une valeur par défaut
    created_at = models.DateTimeField(auto_now_add=True)


class Exercise(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    type = models.CharField(max_length=50)
    difficulty_level = models.IntegerField()
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

class LearningResult(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    score = models.IntegerField()
    submitted_at = models.DateTimeField(auto_now_add=True)

class Badge(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    condition = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

class UserBadge(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    obtained_at = models.DateTimeField(auto_now_add=True)

class Exam(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    exam_type = models.CharField(max_length=50)
    date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

class ExamExercise(models.Model):
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

class LearningHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

class Payment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=50)
    serial_number = models.CharField(max_length=255, unique=True)
    paid_at = models.DateTimeField(auto_now_add=True)

class Admin(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    permissions = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)