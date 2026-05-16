from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from .models import Provider
from .serializers import ProviderSerializer


class AdminProviderListView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        status_filter = request.query_params.get('status', None)
        qs = Provider.objects.all().order_by('-created_at')
        if status_filter and status_filter != 'all':
            qs = qs.filter(verification_status=status_filter)
        serializer = ProviderSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data)


class AdminProviderStatusView(APIView):
    permission_classes = [IsAdminUser]

    def patch(self, request, pk):
        try:
            provider = Provider.objects.get(pk=pk)
            new_status = request.data.get('verification_status')
            if new_status not in ['approved', 'pending', 'rejected', 'suspended']:
                return Response({'error': 'Invalid status'}, status=400)
            provider.verification_status = new_status
            provider.save()
            return Response({'id': provider.id, 'status': provider.verification_status})
        except Provider.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)