from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, CourseViewSet, ExerciseViewSet, LearningResultViewSet, BadgeViewSet, UserBadgeViewSet, ExamViewSet, ExamExerciseViewSet, LearningHistoryViewSet, PaymentViewSet, AdminViewSet, login, register

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'courses', CourseViewSet)
router.register(r'exercises', ExerciseViewSet)
router.register(r'learning-results', LearningResultViewSet)
router.register(r'badges', BadgeViewSet)
router.register(r'user-badges', UserBadgeViewSet)
router.register(r'exams', ExamViewSet)
router.register(r'exam-exercises', ExamExerciseViewSet)
router.register(r'learning-history', LearningHistoryViewSet)
router.register(r'payments', PaymentViewSet)
router.register(r'admins', AdminViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('login/', login, name='login'),
    path('register/', register, name='register'),
]