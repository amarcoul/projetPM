import uuid
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
    etablissement = models.ForeignKey('Etablissement', on_delete=models.SET_NULL, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = UserManager()

    def __str__(self):
        return self.email




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

class Parent(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="parent")
    etablissement = models.ForeignKey('Etablissement', on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Parent: {self.user.first_name} {self.user.last_name}"
    
class Eleve(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="eleve")
    parent = models.ForeignKey('Parent', on_delete=models.SET_NULL, null=True, blank=True, related_name="enfants")
    etablissement = models.ForeignKey('Etablissement', on_delete=models.SET_NULL, null=True, blank=True, related_name="eleves")
    age = models.PositiveIntegerField()
    is_approved = models.BooleanField(default=False)  # Approuvé par le parent ?
    approval_token = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)  # Token de validation

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Élève: {self.user.first_name} {self.user.last_name} - {self.etablissement}"

    class Meta:
        verbose_name = "Élève"
        verbose_name_plural = "Élèves"

class Enseignant(models.Model):
    MATIERE_CHOICES = [
        ("Mathématiques", "Mathématiques"),
        ("Français", "Français"),
        ("Histoire-Géographie", "Histoire-Géographie"),
        ("Sciences", "Sciences"),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="enseignant")
    etablissement = models.ForeignKey('Etablissement', on_delete=models.SET_NULL, null=True, blank=True, related_name="enseignants")
    matiere = models.CharField(max_length=50, choices=MATIERE_CHOICES)  # Choix parmi 4 matières
    type_enseignant = models.CharField(
        max_length=50,
        choices=[("Autonome", "Autonome"), ("Affecté", "Affecté")],
        default="Autonome"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Enseignant: {self.user.first_name} {self.user.last_name} - {self.matiere} - {self.etablissement}"

    class Meta:
        verbose_name = "Enseignant"
        verbose_name_plural = "Enseignants"

class Etablissement(models.Model):
    TYPE_CHOICES = [
        ("Public", "Public"),
        ("Privé", "Privé"),
    ]

    nom = models.CharField(max_length=255, unique=True)  # Nom unique de l'établissement
    adresse = models.TextField()  # Adresse complète
    ville = models.CharField(max_length=100)  # Ville où se situe l'établissement
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default="Public")  # Public ou Privé
    telephone = models.CharField(max_length=20, null=True, blank=True)  # Numéro de téléphone (optionnel)
    email = models.EmailField(unique=True, null=True, blank=True)  # Email de contact (optionnel)
    directeur = models.CharField(max_length=255, null=True, blank=True)  # Nom du directeur
    created_at = models.DateTimeField(auto_now_add=True)  # Date de création de l’établissement

    def __str__(self):
        return f"{self.nom} - {self.ville} ({self.type})"

    class Meta:
        verbose_name = "Établissement"
        verbose_name_plural = "Établissements"

from django.db import models

class Course(models.Model):
    MATIERE_CHOICES = [
        ("Mathématiques", "Mathématiques"),
        ("Français", "Français"),
        ("Histoire-Géographie", "Histoire-Géographie"),
        ("Sciences", "Sciences"),
    ]

    titre = models.CharField(max_length=255)  # Titre du cours/programme
    description = models.TextField()  # Description du contenu du cours
    matiere = models.CharField(max_length=50, choices=MATIERE_CHOICES)  # Matière concernée
    enseignant = models.ForeignKey('Enseignant', on_delete=models.CASCADE, related_name="cours")  # Enseignant responsable
    etablissement = models.ForeignKey('Etablissement', on_delete=models.CASCADE, blank=True, null=True, related_name="cours")  # Établissement lié
    date_publication = models.DateTimeField(auto_now_add=True)  # Date de publication

    def __str__(self):
        return f"{self.titre} - {self.matiere} ({self.enseignant.user.first_name} {self.enseignant.user.last_name})"

class Chapitre(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="chapitres")
    titre = models.CharField(max_length=255)
    numero = models.PositiveIntegerField()  # Permet d'ordonner les chapitres

    def __str__(self):
        return f"Chapitre {self.numero}: {self.titre} ({self.course.titre})"

class Lecon(models.Model):
    chapitre = models.ForeignKey(Chapitre, on_delete=models.CASCADE, related_name="lecons")
    titre = models.CharField(max_length=255)
    fichier_pdf = models.FileField(upload_to='lecons_pdfs/', null=True, blank=True)
    video_url = models.URLField(null=True, blank=True)
    numero = models.PositiveIntegerField()  # Pour organiser les leçons dans l'ordre

    def __str__(self):
        return f"Leçon {self.numero}: {self.titre} ({self.chapitre.titre})"
   

class LearningHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

class Exercise(models.Model):
    DIFFICULTY_CHOICES = [
        (1, 'Facile'),
        (2, 'Moyen'),
        (3, 'Difficile')
    ]
    
    title = models.CharField(max_length=255)
    description = models.TextField()
    subject = models.CharField(max_length=255, null=True, blank=True)  # Ajout du champ subject    type = models.CharField(max_length=50)
    difficulty_level = models.IntegerField(choices=DIFFICULTY_CHOICES)
    duration = models.IntegerField(default=0)  # Exprimé en secondes ou minutes
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    correction = models.TextField()  # Correction de l'exercice
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.title
    
class Question(models.Model):
    exercise = models.ForeignKey(Exercise, related_name='questions', on_delete=models.CASCADE)
    text = models.TextField()
    explanation = models.TextField(blank=True)  # Explication pour la correction
    
    def __str__(self):
        return self.text
class Answer(models.Model):
    question = models.ForeignKey(Question, related_name='answers', on_delete=models.CASCADE)
    text = models.TextField()
    is_correct = models.BooleanField(default=False)
    explanation = models.TextField(blank=True)  # Explication pourquoi cette réponse est correcte/incorrecte
    
    def __str__(self):
        return self.text

class StudentProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    score = models.FloatField(default=0)
    completed = models.BooleanField(default=False)
    last_attempt = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user', 'exercise']


class LearningResult(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    score = models.IntegerField()
    submitted_at = models.DateTimeField(auto_now_add=True)


class ExamExercise(models.Model):
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

from django.utils.timezone import now
class Historique(models.Model):
    user=models.ForeignKey(User,on_delete=models.CASCADE)
    action=models.CharField(max_length=255)
    page=models.CharField(max_length=255)
    timestamp=models.DateTimeField(default=now)

    def __str__(self):
        return f"{self.user.first_name}-{self.action}-{self.timestamp}"