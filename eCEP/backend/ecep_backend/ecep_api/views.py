from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.hashers import make_password
from django.contrib.auth import authenticate
from .models import User, Course, Exercise, LearningResult, Badge, UserBadge, Exam, ExamExercise, LearningHistory, Payment, Admin
from .serializers import (
    UserSerializer, CourseSerializer, ExerciseSerializer, LearningResultSerializer, 
    BadgeSerializer, UserBadgeSerializer, ExamSerializer, ExamExerciseSerializer, 
    LearningHistorySerializer, PaymentSerializer, AdminSerializer
)

# 🔹 Gestion des utilisateurs
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

# 🔹 Inscription
@api_view(['POST'])
def register(request):
    data = request.data
    first_name = data.get('first_name')
    last_name = data.get('last_name')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'eleve')  # Par défaut, rôle élève

    if User.objects.filter(email=email).exists():
        return Response({'error': 'Un utilisateur avec cet email existe déjà.'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=make_password(password),  # Hash du mot de passe
        role=role
    )

    return Response({'message': 'Inscription réussie, veuillez vous connecter.'}, status=status.HTTP_201_CREATED)

# 🔹 Connexion (Authentification avec JWT)
@api_view(['POST'])
def login(request):
    data = request.data
    email = data.get('email')
    password = data.get('password')

    user = User.objects.filter(email=email).first()

    if user is None or not user.check_password(password):
        return Response({'error': 'Email ou mot de passe incorrect.'}, status=status.HTTP_401_UNAUTHORIZED)

    refresh = RefreshToken.for_user(user)  # Générer le token JWT

    return Response({
        'message': 'Connexion réussie',
        'refresh': str(refresh),
        'access': str(refresh.access_token),
        'user': {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'email': user.email,
            'role': user.role,
        }
    }, status=status.HTTP_200_OK)

# 🔹 Gestion des cours
class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

# 🔹 Gestion des exercices
class ExerciseViewSet(viewsets.ModelViewSet):
    queryset = Exercise.objects.all()
    serializer_class = ExerciseSerializer

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
