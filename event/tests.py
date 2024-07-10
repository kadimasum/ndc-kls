from django.test import TestCase, Client
from django.urls import reverse

class EventPageTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_index_page(self):
        response = self.client.get(reverse('index'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'event/index.html')
        self.assertContains(response, 'Kubernetes Learning Series')
        self.assertContains(response, 'Join us for an exciting learning series on Kubernetes')
        self.assertContains(response, 'Date: July 27, 2024')
