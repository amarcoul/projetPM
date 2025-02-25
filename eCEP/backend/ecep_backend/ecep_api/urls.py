from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import get_parent_children_courses,get_user_historique,create_historique,create_exercise,exercises_by_course,submit_exercise,voir_historique,enregistrer_action,CourseDetailView,LeconDetailView,LeconListCreateView,ChapitreDetailView,ChapitreListCreateView,CourseView,get_courses_by_subject,get_course_details,get_teacher_courses,get_courses,CourseListCreateView, CourseUpdateDeleteView,contact,validate_student,UserViewSet, CourseViewSet, ExerciseViewSet, LearningResultViewSet, BadgeViewSet, UserBadgeViewSet, ExamViewSet, ExamExerciseViewSet, LearningHistoryViewSet, PaymentViewSet, AdminViewSet, login, register,register_parent,register_student,register_teacher

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'courses', CourseViewSet)
router.register(r'exercises', ExerciseViewSet,basename='exercise')
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
    path('contact/', contact, name='contact'),
    path('login/', login, name='login'),
    path('register/', register, name='register'),
    path('registereleve/',register_student,name='register_eleve'),
    path('registerparent/',register_parent,name='register_parent'),
    path('registerenseignant/',register_teacher,name='register_enseignant'),
    path('cours/', CourseListCreateView.as_view(), name="cours_list_create"),
    path('create_cours/', CourseView.as_view(), name="course_list"),
    path('create_cours/<int:pk>/', CourseView.as_view(), name="course_detail"),
    path('cours/<int:pk>/', CourseUpdateDeleteView.as_view(), name="cours_update_delete"),

    ###########
    path('validate-student/<str:token>/', validate_student, name='validate_student'),
    ###########

    path('cours/', get_courses, name='get_courses'),
    
    #exercice
    path('exercises/submit/', submit_exercise, name='submit_exercise'), 
    path('exercises/course/<int:course_id>/', exercises_by_course, name='exercises_by_course'),
    path('create_exercises/', create_exercise, name='create_exercise'),

    #cours_ensignant
    path('cours/enseignant/<int:enseignant_id>/', get_teacher_courses, name='get_teacher_courses'),
    path('cours/<int:course_id>/', get_course_details, name='cours-detail'),
    path('cours/<str:subject>/', get_courses_by_subject, name='get_courses_by_subject'),
    
    #cours_eleve
    path('cours/<int:course_id>/chapitres/', ChapitreListCreateView.as_view(), name='chapitre-list-create'),
    path('chapitres/<int:pk>/', ChapitreDetailView.as_view(), name='chapitre-detail'),
    path('chapitres/<int:chapitre_id>/lecons/', LeconListCreateView.as_view(), name='lecon-list-create'),
    path('lecons/<int:pk>/', LeconDetailView.as_view(), name='lecon-detail'),
    
    path('cours/<int:pk>/detail/', CourseDetailView.as_view(), name='course-detail'),

    #historique
    path('historique/<int:user_id>/',get_user_historique,name='historique'),
    path('historique/create/',create_historique,name='vue_historique'),


    #page parent
      #chop les cours de son gosse
    path('parent/<int:parent_id>/cours/', get_parent_children_courses, name='parent-cours'),

    ]