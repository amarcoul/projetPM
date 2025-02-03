from rest_framework import serializers
from .models import User, Course, Exercise, LearningResult, Badge, UserBadge, Exam, ExamExercise, LearningHistory, Payment, Admin

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = '__all__'

class ExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = '__all__'

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