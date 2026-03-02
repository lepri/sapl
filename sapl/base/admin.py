from django.contrib import admin
from django.core.management import call_command
from django.db import connection, transaction
from django_tenants.admin import TenantAdminMixin

from sapl.base.models import AuditLog, Cliente
from sapl.utils import register_all_models_in_admin

register_all_models_in_admin(__name__)

admin.site.site_title = 'Administração - SAPL'
admin.site.site_header = 'Administração - SAPL'

# @admin.register(Cliente)
# class ClientAdmin(TenantAdminMixin, admin.ModelAdmin):
#     list_display = ('name',)


class ClienteAdmin(admin.ModelAdmin):
    list_display = ('nome',)

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)

        if not change:
            transaction.on_commit(lambda: obj.create_schema())


class AuditLogAdmin(admin.ModelAdmin):
    pass

    def has_add_permission(self, request):
        return False

    # def has_change_permission(self, request, obj=None):
    #     return False
    #
    def has_delete_permission(self, request, obj=None):
        return False

    def save_model(self, request, obj, form, change):
        pass

    def delete_model(self, request, obj):
        pass

    def save_related(self, request, form, formsets, change):
        pass


# Na linha acima register_all_models_in_admin registrou AuditLog
admin.site.unregister(AuditLog)
admin.site.register(AuditLog, AuditLogAdmin)

# Safe re-register
if Cliente in admin.site._registry:
    admin.site.unregister(Cliente)

admin.site.register(Cliente, ClienteAdmin)
