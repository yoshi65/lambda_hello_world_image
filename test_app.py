import json
import unittest

from app import handler


class HandlerTest(unittest.TestCase):
    def test_returns_hello_world_response(self):
        response = handler({}, None)

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(json.loads(response["body"]), {"message": "hello world"})


if __name__ == "__main__":
    unittest.main()
