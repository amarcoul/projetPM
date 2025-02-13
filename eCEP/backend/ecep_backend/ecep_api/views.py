from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.hashers import make_password
from django.contrib.auth import authenticate
from .models import StudentProgress,Question,Answer,User, Course, Exercise, LearningResult, Badge, UserBadge, Exam, ExamExercise, LearningHistory, Payment, Admin,Parent, Eleve, Enseignant, Etablissement
from .serializers import (
    UserSerializer, CourseSerializer, ExerciseSerializer, LearningResultSerializer, 
    BadgeSerializer, UserBadgeSerializer, ExamSerializer, ExamExerciseSerializer, 
    LearningHistorySerializer, PaymentSerializer, AdminSerializer
)
from django.http import JsonResponse
# 🔹 Gestion des utilisateurs
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

# 🔹 Inscription
@api_view(['POST'])
def register(request):
    first_name = request.data.get("first_name")
    last_name = request.data.get("last_name")
    email = request.data.get("email")
    password = request.data.get("password")
    role = request.data.get("role")
    etablissement_id = request.data.get("etablissement_id")
    parent_id = request.data.get("parent_id")  # Pour les élèves seulement

    if not all([first_name, last_name, email, password, role]):
        return JsonResponse({"error": "Tous les champs sont requis"}, status=400)

    # Vérifier que l'établissement existe
    try:
        etablissement = Etablissement.objects.get(id=etablissement_id)
    except Etablissement.DoesNotExist:
        return JsonResponse({"error": "L'établissement spécifié n'existe pas"}, status=400)

    # Vérifier les conditions spécifiques aux rôles
    if role == "eleve":
        if not parent_id:
            return JsonResponse({"error": "Un élève doit avoir un parent"}, status=400)
        try:
            parent = Parent.objects.get(id=parent_id)
        except Parent.DoesNotExist:
            return JsonResponse({"error": "Le parent spécifié n'existe pas"}, status=400)
    
    elif role == "parent":
        parent = None  # Un parent ne nécessite pas de parent

    elif role == "enseignant":
        parent = None  # Un enseignant ne nécessite pas de parent

    elif role == "admin":
        parent = None  # Un admin ne nécessite pas de parent

    else:
        return JsonResponse({"error": "Rôle invalide"}, status=400)

    # Créer l'utilisateur
    user = User.objects.create(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=make_password(password),
        role=role,
        etablissement=etablissement
    )

    # Créer les objets spécifiques aux rôles
    if role == "eleve":
        Eleve.objects.create(user=user, parent=parent, etablissement=etablissement)
    elif role == "parent":
        Parent.objects.create(user=user, etablissement=etablissement)
    elif role == "enseignant":
        Enseignant.objects.create(user=user, etablissement=etablissement)

    return JsonResponse({"message": "Inscription réussie", "user_id": user.id})

# 🔹 Connexion (Authentification avec JWT)
@api_view(['POST'])
def login(request):
    email = request.data.get("email")
    password = request.data.get("password")
    role = request.data.get("role")  # ✅ Vérifier le rôle fourni par l'utilisateur

    user = authenticate(email=email, password=password)

    if user is not None:
        if user.role != role:  # ✅ Vérifier que le rôle correspond bien
            return JsonResponse({"error": "Accès refusé : rôle incorrect"}, status=403)

        refresh = RefreshToken.for_user(user)
        return JsonResponse({
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": {
                "id": user.id,
                "email": user.email,
                "role": user.role,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "password": user.password
            }
        })
    else:
        return JsonResponse({"error": "Email ou mot de passe incorrect"}, status=401)


# 🔹 Gestion des cours
class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

# 🔹 Gestion des résultats d'apprentissage
class LearningResultViewSet(viewsets.ModelViewSet):
    queryset = LearningResult.objects.all()
    serializer_class = LearningResultSerializer

# 🔹 Gestion des badges
class BadgeViewSet(viewsets.ModelViewSet):
    queryset = Badge.objects.all()
    serializer_class = BadgeSerializer

# 🔹 Gestion des badges des utilisateurs
class UserBadgeViewSet(viewsets.ModelViewSet):
    queryset = UserBadge.objects.all()
    serializer_class = UserBadgeSerializer

# 🔹 Gestion des examens
class ExamViewSet(viewsets.ModelViewSet):
    queryset = Exam.objects.all()
    serializer_class = ExamSerializer

# 🔹 Gestion des exercices d'examen
class ExamExerciseViewSet(viewsets.ModelViewSet):
    queryset = ExamExercise.objects.all()
    serializer_class = ExamExerciseSerializer

# 🔹 Gestion de l'historique d'apprentissage
class LearningHistoryViewSet(viewsets.ModelViewSet):
    queryset = LearningHistory.objects.all()
    serializer_class = LearningHistorySerializer

# 🔹 Gestion des paiements
class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer

# 🔹 Gestion des administrateurs
class AdminViewSet(viewsets.ModelViewSet):
    queryset = Admin.objects.all()
    serializer_class = AdminSerializer


from django.shortcuts import redirect

from django.http import JsonResponse
from django.shortcuts import redirect

@api_view(['GET'])
def validate_student(request, token):
    try:
        eleve = Eleve.objects.get(approval_token=token, is_approved=False)
    except Eleve.DoesNotExist:
        return Response({"error": "Lien invalide ou élève déjà validé."}, status=status.HTTP_400_BAD_REQUEST)

    # Vérifier si un parent existe
    try:
        parent = Parent.objects.get(user__email=eleve.user.email.split("+")[0])
        # 🔹 Si le parent existe, valider l'élève
        eleve.parent = parent
        eleve.is_approved = True
        eleve.approval_token = None  # Supprimer le token après validation
        eleve.save()
        return Response({"message": "L'élève a été validé avec succès."}, status=status.HTTP_200_OK)
    except Parent.DoesNotExist:
        # 🔹 Si le parent n'existe pas, rediriger vers l'inscription Flutter
        flutter_signup_url = f"https://mon-app-flutter.com/register?email={eleve.user.email.split('+')[0]}&eleve_id={eleve.id}"
        return redirect(flutter_signup_url)

from django.core.mail import send_mail
from django.conf import settings
from django.urls import reverse
import uuid
# 🔹 Inscription Élève
@api_view(['POST'])
def register_student(request):
    first_name = request.data.get("first_name")
    last_name = request.data.get("last_name")
    email = request.data.get("email")
    password = request.data.get("password")
    age = request.data.get("age")
    parent_email = request.data.get("parent_email")
    etablissement_id = request.data.get("etablissement_id", None)
    
    if not all([first_name, last_name, email, password, age, parent_email]):
        return Response({"error": "Tous les champs sont requis"}, status=status.HTTP_400_BAD_REQUEST)

    etablissement = Etablissement.objects.get(id=etablissement_id) if etablissement_id else None
    
    user = User.objects.create(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=make_password(password),
        role='eleve',
        etablissement=etablissement
    )
    approval_token = str(uuid.uuid4())
    eleve = Eleve.objects.create(user=user, etablissement=etablissement, parent=None, age=age, is_approved=False, approval_token=approval_token)
    flutter_signup_url = f"https://mon-app-flutter.com/register?email={email}&eleve_id={user.id}"

    send_mail(
    subject="Validation d'inscription de votre enfant",
    message=f"Bonjour,\n\nVotre enfant {first_name} {last_name} s'est inscrit sur notre plateforme.\n\n"
            f"Veuillez cliquer sur ce lien pour valider son inscription :\n{flutter_signup_url}\n\n"
            f"Si vous n'avez pas encore de compte parent, inscrivez-vous ici : {flutter_signup_url}\n\n"
            f"Si vous ne reconnaissez pas cette demande, ignorez cet e-mail.",
    from_email=settings.DEFAULT_FROM_EMAIL,
    recipient_list=[parent_email],
    fail_silently=False,
    )


    return Response({"message": "Inscription réussie, un e-mail de validation a été envoyé au parent s'il n'aprouve pas dans 7jours votre compte sera automatique supprime."}, status=status.HTTP_201_CREATED)

# 🔹 Inscription Parent
@api_view(['POST'])
def register_parent(request):
    first_name = request.data.get("first_name")
    last_name = request.data.get("last_name")
    email = request.data.get("email")
    password = request.data.get("password")
    etablissement_id = request.data.get("etablissement_id", None)
    eleve_id = request.data.get("eleve_id")  # Récupérer l'ID de l'élève si disponible

    if not all([first_name, last_name, email, password]):
        return Response({"error": "Tous les champs sont requis"}, status=status.HTTP_400_BAD_REQUEST)

    etablissement = Etablissement.objects.get(id=etablissement_id) if etablissement_id else None

    # 🔹 Créer le compte parent
    user = User.objects.create(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=make_password(password),
        role='parent',
        etablissement=etablissement
    )
    parent = Parent.objects.create(user=user, etablissement=etablissement)

    # 🔹 Activer l'élève si l'ID est fourni
    if eleve_id:
        try:
            eleve = Eleve.objects.get(id=eleve_id, is_approved=False)
            eleve.parent = parent
            eleve.is_approved = True
            eleve.approval_token = None  # Supprimer le token après validation
            eleve.save()
        except Eleve.DoesNotExist:
            return Response({"error": "Aucun élève trouvé à activer."}, status=status.HTTP_404_NOT_FOUND)

    return Response({"message": "Inscription réussie. Votre enfant a été validé automatiquement.", "user_id": user.id}, status=status.HTTP_201_CREATED)

# 🔹 Inscription Enseignant
@api_view(['POST'])
def register_teacher(request):
    first_name = request.data.get("first_name")
    last_name = request.data.get("last_name")
    email = request.data.get("email")
    password = request.data.get("password")
    etablissement_id = request.data.get("etablissement_id", None)
    teacher_type = request.data.get("teacher_type", "Autonome")
    subjects = request.data.get("subjects", [])
    
    if not all([first_name, last_name, email, password]):
        return Response({"error": "Tous les champs sont requis"}, status=status.HTTP_400_BAD_REQUEST)
    
    etablissement = Etablissement.objects.get(id=etablissement_id) if etablissement_id else None
    
    user = User.objects.create(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=make_password(password),
        role='enseignant',
        etablissement=etablissement
    )
    enseignant=Enseignant.objects.create(user=user, etablissement=etablissement, matiere=subjects[0] if subjects else "maths")
    return Response({"message": "Inscription réussie", "enseignant_id": enseignant.id}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
def contact(request):
    name = request.data.get("name")  # Correction ici
    email = request.data.get("email")  # Correction ici
    message = request.data.get("message")  # Correction ici

    if not all([name, email, message]):
        return Response({"error": "Tous les champs sont requis"}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        send_mail(
            subject=f"Message de la part de MR/Mme {name}",
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[settings.DEFAULT_FROM_EMAIL],
            fail_silently=False,
        )
        return Response({"message": "Email envoyé avec succès"}, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
from rest_framework import generics

class CourseListCreateView(generics.ListCreateAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

@api_view(['GET'])
def get_course_details(request, course_id):
    """Récupère un cours avec ses chapitres et leçons"""
    try:
        course = Course.objects.get(id=course_id)
        serializer = CourseSerializer(course)
        return Response(serializer.data)
    except Course.DoesNotExist:
        return Response({"error": "Cours non trouvé"}, status=404)

class CourseUpdateDeleteView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

@api_view(['GET'])
def get_courses(request):
    subject = request.GET.get('subject', None)  # Filtre par matière
    search = request.GET.get('search', None)  # Filtre par mot-clé

    courses = Course.objects.all()

    if subject:
        courses = courses.filter(subject__icontains=subject)  # Filtrer par matière
    if search:
        courses = courses.filter(title__icontains=search)  # Rechercher par titre

    serializer = CourseSerializer(courses, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


class ExerciseViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Exercise.objects.all()
    serializer_class = ExerciseSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        subject = self.request.query_params.get('subject', None)
        if subject:
            queryset = queryset.filter(subject=subject)
        return queryset

@api_view(['POST'])
def submit_exercise(request):
    exercise_id = request.data.get('exercise_id')
    answers = request.data.get('answers', [])
    
    if not exercise_id:
        return Response({'error': 'Exercise ID is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        exercise = Exercise.objects.get(id=exercise_id)
        correct_count = 0
        total_questions = exercise.questions.count()
        
        for answer in answers:
            question_id = answer.get('question_id')
            selected_answers = answer.get('selected_answers', [])
            
            if not question_id:
                continue  # Ignore les réponses sans question_id
            
            try:
                question = Question.objects.get(id=question_id)
                correct_answers = set(question.answers.filter(is_correct=True).values_list('id', flat=True))
                selected_answers = set(selected_answers)
                
                if correct_answers == selected_answers:
                    correct_count += 1
            except Question.DoesNotExist:
                continue  # Ignore les questions non trouvées
        
        score = (correct_count / total_questions) * 100 if total_questions > 0 else 0
        
        StudentProgress.objects.update_or_create(
            user=request.user,
            exercise=exercise,
            defaults={
                'score': score,
                'completed': True
            }
        )
        
        return Response({
            'score': score,
            'correct_count': correct_count,
            'total_questions': total_questions,
            'correction': exercise.correction
        })
        
    except Exercise.DoesNotExist:
        return Response({'error': 'Exercise not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_teacher_courses(request, enseignant_id):
    try:
        # Vérifie si l'utilisateur est un enseignant
        enseignant = Enseignant.objects.get(id=enseignant_id)
        # Filtre les cours créés par cet enseignant
        courses = Course.objects.filter(enseignant=enseignant)
        
        serializer = CourseSerializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Enseignant.DoesNotExist:
        return Response({"error": "Aucun enseignant trouvé"}, status=status.HTTP_404_NOT_FOUND)
    
from django.utils.text import slugify
import logging

logger = logging.getLogger(__name__)
@api_view(['GET'])
def get_courses_by_subject(request, subject):
    """Retourne les cours filtrés par matière"""
    
    logger.info(f"Requête reçue pour la matière: {subject}")  # 🔹 Debugging
    print(f"Requête reçue pour la matière: {subject}")  # Log console

    matieres_valides = ["Mathématiques", "Français", "Histoire-Géographie", "Sciences"]

    if subject not in matieres_valides:
        print(f"⚠️ Matière non trouvée: {subject}")
        return Response({"error": f"Matière non trouvée: {subject}"}, status=404)

    cours = Course.objects.filter(matiere=subject)
    print(f"📌 Cours trouvés : {cours}")  # Log des cours retournés

    serializer = CourseSerializer(cours, many=True)
    return Response({"chapitres": serializer.data})

from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
class CourseView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        print("✅ Requête reçue:", request.data) 
        serializer = CourseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        print("Erreurs du formulaire:", serializer.errors)  # Ajout du log
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        course = Course.objects.get(pk=pk)
        serializer = CourseSerializer(course, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

from .models import Chapitre, Lecon
from .serializers import ChapitreSerializer, LeconSerializer
class ChapitreListCreateView(APIView):
    def get(self, request, course_id):
        """Get all chapters for a specific course"""
        chapitres = Chapitre.objects.filter(course_id=course_id).order_by('numero')
        serializer = ChapitreSerializer(chapitres, many=True)
        return Response(serializer.data)

    def post(self, request, course_id):
        """Create a new chapter for a specific course"""
        # Add course_id to request data
        data = request.data.copy()
        data['course'] = course_id
        
        serializer = ChapitreSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from django.shortcuts import get_object_or_404
class ChapitreDetailView(APIView):
    def get(self, request, pk):
        """Get a specific chapter"""
        chapitre = get_object_or_404(Chapitre, pk=pk)
        serializer = ChapitreSerializer(chapitre)
        return Response(serializer.data)

    def put(self, request, pk):
        """Update a specific chapter"""
        chapitre = get_object_or_404(Chapitre, pk=pk)
        serializer = ChapitreSerializer(chapitre, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        """Delete a specific chapter"""
        chapitre = get_object_or_404(Chapitre, pk=pk)
        chapitre.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class LeconListCreateView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request, chapitre_id):
        """Get all lessons for a specific chapter"""
        lecons = Lecon.objects.filter(chapitre_id=chapitre_id).order_by('numero')
        serializer = LeconSerializer(lecons, many=True)
        return Response(serializer.data)

    def post(self, request, chapitre_id):
        """Create a new lesson for a specific chapter"""
        # Add chapitre_id to request data
        data = request.data.copy()
        data['chapitre'] = chapitre_id
        
        serializer = LeconSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LeconDetailView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request, pk):
        """Get a specific lesson"""
        lecon = get_object_or_404(Lecon, pk=pk)
        serializer = LeconSerializer(lecon)
        return Response(serializer.data)

    def put(self, request, pk):
        """Update a specific lesson"""
        lecon = get_object_or_404(Lecon, pk=pk)
        serializer = LeconSerializer(lecon, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        """Delete a specific lesson"""
        lecon = get_object_or_404(Lecon, pk=pk)
        lecon.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class CourseDetailView(APIView):
    def get(self, request, pk):
        """Get a specific course with all its chapters and lessons"""
        course = get_object_or_404(Course, pk=pk)
        # Récupérer les chapitres avec leurs leçons
        chapitres = Chapitre.objects.filter(course=course).order_by('numero')
        chapitres_data = []
        
        for chapitre in chapitres:
            chapitre_serializer = ChapitreSerializer(chapitre)
            chapitre_data = chapitre_serializer.data
            
            # Récupérer les leçons pour ce chapitre
            lecons = Lecon.objects.filter(chapitre=chapitre).order_by('numero')
            lecons_serializer = LeconSerializer(lecons, many=True)
            chapitre_data['lecons'] = lecons_serializer.data
            
            chapitres_data.append(chapitre_data)
        
        # Ajouter les chapitres à la réponse du cours
        course_data = CourseSerializer(course).data
        course_data['chapitres'] = chapitres_data
        
        return Response(course_data)
    
from .models import Historique    
from django.utils.timezone import now   
@api_view(['POST'])
def enregistrer_action(request):
    user=request.user
    action=request.data.get('action')
    page=request.data.get('page','')

    if action:
        Historique.objects.create(user=user,action=action,page=page,timestamp=now())
    return Response({"error":"L'action est requise"},status=400)

@api_view(['GET'])
def voir_historique(request0):
    return 0