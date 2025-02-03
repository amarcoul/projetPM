from django.contrib import admin
from .models import User, Course, Exercise, LearningResult, Badge, UserBadge, Exam, ExamExercise, LearningHistory, Payment, Admin

admin.site.register(User)
admin.site.register(Course)
admin.site.register(Exercise)
admin.site.register(LearningResult)
admin.site.register(Badge)
admin.site.register(UserBadge)
admin.site.register(Exam)
admin.site.register(ExamExercise)
admin.site.register(LearningHistory)
admin.site.register(Payment)
admin.site.register(Admin)
