from rest_framework import serializers
from .models import StudentProgress,Question,Answer,Lecon,Chapitre,User, Course, Exercise, LearningResult, Badge, UserBadge, Exam, ExamExercise, LearningHistory, Payment, Admin

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class LeconSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lecon
        fields = '__all__'

class ChapitreSerializer(serializers.ModelSerializer):
    lecons = LeconSerializer(many=True, read_only=True)  # Liste des leçons dans le chapitre

    class Meta:
        model = Chapitre
        fields = '__all__'

class CourseSerializer(serializers.ModelSerializer):
    chapitres = ChapitreSerializer(many=True, read_only=True)  # Liste des chapitres dans le cours

    class Meta:
        model = Course
        fields = '__all__'
    def validate(self, data):
        print("Données reçues :", data)  # Ajout pour débogage
        return data
    
class AnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Answer
        fields = '__all__'

class QuestionSerializer(serializers.ModelSerializer):
    answers = AnswerSerializer(many=True, read_only=True)
    
    class Meta:
        model = Question
        fields ='__all__'

class ExerciseSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, read_only=True)
    course_title = serializers.CharField(source='course.title', read_only=True)
    progress = serializers.SerializerMethodField()
    
    class Meta:
        model = Exercise
        fields = '__all__'
    def get_progress(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            progress = StudentProgress.objects.filter(
                user=request.user,
                exercise=obj
            ).first()
            return progress.score if progress else 0
        return 0
    
class LearningResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = LearningResult
        fields = '__all__'

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = '__all__'

class UserBadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserBadge
        fields = '__all__'

class ExamSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exam
        fields = '__all__'

class ExamExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExamExercise
        fields = '__all__'

class LearningHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = LearningHistory
        fields = '__all__'

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = '__all__'

class AdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = '__all__'